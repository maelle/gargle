verify_recorded_error <- function(filename, status_code) {
  rds_file <- test_path("fixtures", fs::path_ext_set(filename, "rds"))
  output_file <- glue("{fs::path_ext_remove(rds_file)}_MESSAGE.txt")

  resp <- readRDS(rds_file)
  expect_error(response_process(resp), class = "gargle_error_request_failed")
  expect_error(response_process(resp), class = glue("http_error_{status_code}"))
  verify_output(output_file, response_process(resp))
}

test_that("Use key that's not enabled for the API (Sheets)", {
  verify_recorded_error("sheets-spreadsheets-get-api-key-not-enabled_403", 403)
})

test_that("Request with invalid argument (Sheets, bad range)", {
  verify_recorded_error("sheets-spreadsheets-get-nonexistent-range_400", 400)
})

test_that("Request with bad field mask (Sheets)", {
  verify_recorded_error("sheets-spreadsheets-get-bad-field-mask_400", 400)
})

test_that("Request for nonexistent resource (Sheets)", {
  verify_recorded_error("sheets-spreadsheets-get-nonexistent-sheet-id_404", 404)
})

test_that("Request for non-existent resource (Drive)", {
  verify_recorded_error("drive-files-get-nonexistent-file-id_404", 404)
})

test_that("Request with invalid value (tokeninfo, stale token)", {
  verify_recorded_error("tokeninfo-stale_400", 400)
})

test_that("Request to bad URL (tokeninfo, HTML content)", {
  verify_recorded_error("tokeninfo-bad-path_404", 404)
})

test_that("Resource exhausted (Sheets, ReadGroup)", {
  verify_recorded_error(
    "sheets-spreadsheets-get-quota-exceeded-readgroup_429",
    429
  )
})

test_that("RPC codes can be looked up (or not)", {
  expect_match(
    rpc_description("ALREADY_EXISTS"),
    "resource .* already exists"
  )
  expect_null(rpc_description("MATCHES_NOTHING"))
})
