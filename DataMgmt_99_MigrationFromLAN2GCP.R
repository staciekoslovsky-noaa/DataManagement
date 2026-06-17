# Migrate data to Google Cloud Storage Buckets from AFSC LAN
# Gemini and S. Koslovsky, June 2026

library(googleCloudStorageR)
library(tidyverse)
library(tools)
library(fs)
library(stringr)
library(openssl) # Needed to convert Hex MD5 to Base64 for GCS validation
library(gargle)

# --- 0. Run This Code Before Running the Rest ---

# Clear the environment variable so the script stops looking for a file
Sys.unsetenv("GCS_AUTH_FILE")

# Tell gargle to grab the token directly from your active gcloud CLI
gcp_token <- gargle::token_fetch(
  scopes = "https://www.googleapis.com/auth/cloud-platform"
)

# Pass that token straight into the GCS auth function
gcs_auth(token = gcp_token)

# --- 1. Configuration ---
fromLAN <- "\\\\akc0ss-n086\\NMML_Polar_Imagery\\Surveys_HS\\Glacial\\Originals\\"
fromFolder <- "2005"

# GCP Destination Settings
gcp_project <- "ggn-nmfs-afscinf-infra-01" # Replace with your actual GCP Project ID
gcp_bucket <- "afsc_mml_pep" # Replace with your actual GCS Bucket Name
toFolder <- "Survey_HarborSeal_Glacial"
subFolder <- "2005"

include_toFolder <- TRUE # TRUE = Prepend 'toFolder' to the GCS path
create_subfolder <- TRUE # TRUE = Prepend 'subFolder' inside toFolder

# Manifest Configuration
manifest_file <- "filesFrom_PolarImagery_SurveysHS_Glacial_2005.csv"
save_interval <- 5

# Update this to a reliable local or network path for logging your progress
manifest_path <- paste0(
  "G:\\Shared drives\\NMFS MML PEP Data\\CloudMigration_manifestLogs\\",
  manifest_file
)

# Helper function to strip single quotes
sanitize_name <- function(x) {
  str_replace_all(x, "'", "")
}


# --- 2. Set GCP Bucket and Destination Prefix ---
gcs_global_bucket(gcp_bucket)

# Build the base prefix folder string for GCS
base_prefix <- ""
if (include_toFolder) {
  base_prefix <- toFolder
}
if (create_subfolder) {
  base_prefix <- if (base_prefix == "") {
    subFolder
  } else {
    paste0(base_prefix, "/", subFolder)
  }
}


# --- 3. Manifest Management ---
local_full_path <- path(fromLAN, fromFolder)

# Ensure the local log directory exists
dir_create(path_dir(manifest_path))

if (file_exists(manifest_path)) {
  message("Resuming from existing manifest...")
  manifest <- read_csv(manifest_path, show_col_types = FALSE)
} else {
  message("Scanning network drive...")
  # 1. Grab raw info first without manipulating paths yet
  manifest <- dir_info(local_full_path, recurse = TRUE, type = "file") %>%
    select(local_path = path, size_bytes = size) %>%
    mutate(path_length = nchar(as.character(local_path))) # Calculate length using base R

  # 2. --- CRITICAL PATH LENGTH CHECK ---
  # Check if any original network paths exceed the Windows 260-character limit
  long_paths_count <- sum(manifest$path_length > 260)

  if (long_paths_count > 0) {
    cat("\n🛑 MIGRATION HALTED: Path Length Violation!\n")
    cat(str_glue(
      "Found {long_paths_count} files with paths exceeding 260 characters.\n"
    ))
    cat(
      "The raw, unmutated dataset is preserved in your environment as 'manifest'.\n"
    )
    cat(
      "Run the following snippet in your console to view and export the problem folders:\n\n"
    )
    cat(
      "  manifest %>% filter(path_length > 260) %>% select(path_length, local_path)\n\n"
    )

    stop(
      "Please fix these long folder paths on the AFSC LAN before running this script again."
    )
  }

  # 3. Safe to proceed with fs operations since all paths are clean (< 260 chars)
  manifest <- manifest %>%
    select(-path_length) %>% # Drop helper column so it doesn't clutter the CSV
    mutate(
      rel_path = path_rel(local_path, start = local_full_path),
      rel_dir = path_dir(rel_path),
      filename = path_file(local_path),
      status = "Pending",
      checksum_match = NA,
      timestamp = as.POSIXct(NA)
    )

  # MANDATORY CLEANING STEP:
  # This ensures the manifest is updated to use "Clean" names for Google Drive
  manifest <- manifest %>%
    mutate(
      filename = sanitize_name(filename),
      rel_dir = sanitize_name(rel_dir)
    )

  write_csv(manifest, manifest_path)
}


# --- 4. The Upload Engine ---
indices_to_process <- which(
  manifest$status %in% c("Pending", "Checksum Failed")
)

walk(indices_to_process, function(idx) {
  row <- manifest[idx, ]

  tryCatch(
    {
      # Build the flat object path for GCS (e.g., "Counts/Subfolder/file.jpg")
      path_parts <- c(base_prefix, row$rel_dir, row$filename)
      path_parts <- path_parts[path_parts != "." & path_parts != ""]
      gcs_object_path <- paste(path_parts, collapse = "/")

      # Upload file directly to GCS
      uploaded_object <- gcs_upload(
        file = row$local_path,
        name = gcs_object_path,
        predefinedAcl = "bucketLevel"
      )

      # --- Checksum Verification ---
      # Stream the local file directly into openssl to get the raw binary hash
      local_md5_raw <- openssl::md5(file(row$local_path))

      # Convert those raw binary bytes directly to a Base64 string to match GCS
      local_md5_base64 <- openssl::base64_encode(local_md5_raw)

      remote_md5_base64 <- uploaded_object$md5Hash

      # Update local manifest in memory
      manifest$timestamp[idx] <<- Sys.time()
      if (local_md5_base64 == remote_md5_base64) {
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
