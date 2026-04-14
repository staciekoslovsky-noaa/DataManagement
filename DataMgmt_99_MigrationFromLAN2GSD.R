# Migrate data to Google Share Drives from AFSC LAN
# Gemini and S. Koslovsky, February 2026

library(googledrive)
library(tidyverse)
library(tools)
library(fs)
library(stringr)

# --- 0. Run This Code Before Running the Rest ---
googledrive::drive_auth()


# --- 1. Configuration ---
fromLAN <- "\\\\akc0ss-n086\\NMML_Polar_Imagery\\Surveys_HS\\Glacial\\Projects\\"
fromFolder <- "Counts"
toShareDrive <- "NMFS MML PEP Survey Harbor Seal Glacial"
toFolder <- "Counts"
#subFolder <- "2004"

include_top_folder <- TRUE # TRUE = Create/use 'toFolder'
create_subfolder <- FALSE # TRUE = Create/use 'subFolder' inside toFolder

manifest_file <- "filesFrom_PolarImagery_SurveysHS_Glacial_Counts.csv"
save_interval <- 5

# Helper function to strip single quotes
sanitize_name <- function(x) {
  # Replaces single quotes with nothing.
  # You could also use "_" if you prefer a placeholder.
  str_replace_all(x, "'", "")
}

# --- 2. Identify Target Root on Shared Drive ---
# Find the Shared Drive first
sd_match <- shared_drive_find(pattern = paste0("^", toShareDrive, "$"))

if (nrow(sd_match) != 1) {
  stop(str_glue(
    "Shared Drive '{toShareDrive}' not found or there are too many! Check permissions or figure your $*!+ out."
  ))
}

shared_drive_id <- as_id(sd_match$id[1])

# Determine the starting point on Google Drive
# if (include_top_folder) {
#   # Check if the 'toFolder' container exists, create if not
#   target_root_obj <- drive_ls(shared_drive_id, pattern = toFolder) %>%
#     filter(name == toFolder) %>%
#     {
#       if (nrow(.) > 0) . else drive_mkdir(toFolder, path = shared_drive_id)
#     }
# } else {
#   # Upload directly to the root of the Shared Drive
#   target_root_obj <- drive_get(shared_drive_id)
# }

# --- 2. Identify Target Root on Shared Drive ---

# Start at the root of the Shared Drive
current_target_id <- shared_drive_id

# Logic for Top Folder
if (include_top_folder) {
  top_match <- drive_ls(current_target_id, pattern = toFolder) %>%
    filter(name == toFolder)
  if (nrow(top_match) > 0) {
    current_target_id <- as_id(top_match$id[1])
  } else {
    current_target_id <- drive_mkdir(toFolder, path = current_target_id)$id
  }
}

# Logic for Subfolder (nested inside whatever is current)
if (create_subfolder) {
  sub_match <- drive_ls(current_target_id, pattern = subFolder) %>%
    filter(name == subFolder)
  if (nrow(sub_match) > 0) {
    current_target_id <- as_id(sub_match$id[1])
  } else {
    current_target_id <- drive_mkdir(subFolder, path = current_target_id)$id
  }
}

# This is the final ID used by the upload engine
target_root_id <- current_target_id


# --- 3. Manifest Management ---
manifest_path <- paste0(
  "G:\\Shared drives\\NMFS MML PEP Data\\CloudMigration_manifestLogs\\",
  manifest_file
)
local_full_path <- path(fromLAN, fromFolder)

if (file_exists(manifest_path)) {
  message("Resuming from existing manifest...")
  manifest <- read_csv(manifest_path, show_col_types = FALSE)
} else {
  message("Scanning network drive...")
  # dir_info is much faster and cleaner than list.files
  manifest <- dir_info(local_full_path, recurse = TRUE, type = "file") %>%
    select(local_path = path, size_bytes = size) %>%
    mutate(
      rel_path = path_rel(local_path, start = local_full_path),
      rel_dir = path_dir(rel_path),
      filename = path_file(local_path),
      status = "Pending",
      checksum_match = NA,
      timestamp = as.POSIXct(NA)
    )

  # MANDATORY CLEANING STEP:
  # This ensures even an existing manifest is updated to use "Clean" names for Drive
  manifest <- manifest %>%
    mutate(
      filename = sanitize_name(path_file(local_path)),
      rel_dir = sanitize_name(path_dir(path_rel(
        local_path,
        start = local_full_path
      )))
    )

  write_csv(manifest, manifest_path)
}


# --- 4. The Upload Engine ---
# Create a cache to store folder IDs to avoid redundant API calls
# folder_cache <- list("." = target_root_obj$id)
folder_cache <- list("." = target_root_id)

# Iterate through indices using purrr::walk
indices_to_process <- which(
  manifest$status %in% c("Pending", "Checksum Failed")
)

walk(indices_to_process, function(idx) {
  row <- manifest[idx, ]

  tryCatch(
    {
      # Resolve subdirectories
      current_parent <- folder_cache[["."]]

      if (row$rel_dir != ".") {
        path_parts <- str_split(row$rel_dir, "/")[[1]]
        acc_path <- ""

        for (part in path_parts) {
          acc_path <- if (acc_path == "") part else path(acc_path, part)

          if (is.null(folder_cache[[acc_path]])) {
            # Idempotent check: Does folder exist on Drive?
            existing_folder <- drive_ls(
              as_id(current_parent),
              pattern = part
            ) %>%
              filter(name == part)

            if (nrow(existing_folder) > 0) {
              folder_cache[[acc_path]] <<- existing_folder$id[1]
            } else {
              new_folder <- drive_mkdir(part, path = as_id(current_parent))
              folder_cache[[acc_path]] <<- new_folder$id
            }
          }
          current_parent <- folder_cache[[acc_path]]
        }
      }

      # Upload file
      uploaded_file <- drive_upload(
        media = row$local_path,
        path = as_id(current_parent),
        name = row$filename,
        overwrite = TRUE
      )

      # Checksum Verification
      local_md5 <- md5sum(row$local_path)
      remote_md5 <- uploaded_file$drive_resource[[1]]$md5Checksum

      # Update local manifest in memory
      manifest$timestamp[idx] <<- Sys.time()
      if (local_md5 == remote_md5) {
        manifest$status[idx] <<- "Done"
        manifest$checksum_match[idx] <<- TRUE
      } else {
        # Retry logic
        new_status <- if_else(
          row$status == "Checksum Failed",
          "Permanent Failure",
          "Checksum Failed"
        )
        manifest$status[idx] <<- new_status
        manifest$checksum_match[idx] <<- FALSE
      }

      # Checkpoint save
      if (idx %% save_interval == 0) {
        write_csv(manifest, manifest_path)
      }

      message(str_glue(
        "Processed: {row$filename} | Status: {manifest$status[idx]}"
      ))
    },
    error = function(e) {
      message(str_glue("Error at {row$filename}: {e$message}"))
      write_csv(manifest, manifest_path)
    }
  )
})

# Final write-out
write_csv(manifest, manifest_path)

# --- 5. Summary Report ---
cat("\n--- FINAL MIGRATION REPORT ---\n")

report <- manifest %>%
  group_by(status) %>%
  summarise(
    File_Count = n(),
    Total_GB = round(sum(as.numeric(size_bytes)) / 1024^3, 3)
  )

print(report)

if ("Permanent Failure" %in% manifest$status) {
  cat("\nWARNING: The following files failed checksum verification twice:\n")
  manifest %>%
    filter(status == "Permanent Failure") %>%
    select(filename, local_path) %>%
    print()
}
