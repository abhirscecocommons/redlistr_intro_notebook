# Safe key loader for rredlist demos.
# Priority: existing environment variable -> .env file -> interactive helper.

load_iucn_key <- function(interactive_fallback = TRUE) {
  key <- Sys.getenv("IUCN_REDLIST_KEY", unset = "")
  if (nzchar(key)) return(key)

  env_file <- file.path(getwd(), ".env")
  if (file.exists(env_file)) {
    lines <- readLines(env_file, warn = FALSE)
    hit <- grep("^IUCN_REDLIST_KEY=", lines, value = TRUE)
    if (length(hit) > 0) {
      key <- sub("^IUCN_REDLIST_KEY=", "", hit[[1]])
      if (nzchar(key)) {
        Sys.setenv(IUCN_REDLIST_KEY = key)
        return(key)
      }
    }
  }

  if (interactive() && interactive_fallback) {
    message("No key found. Launching rredlist::rl_use_iucn()...")
    rredlist::rl_use_iucn()
    key <- Sys.getenv("IUCN_REDLIST_KEY", unset = "")
    if (nzchar(key)) return(key)
  }

  stop(
    paste(
      "IUCN_REDLIST_KEY is not set.",
      "Set it in your shell, .Renviron, or local .env file.",
      sep = "\n"
    ),
    call. = FALSE
  )
}

init_rredlist <- function() {
  if (!requireNamespace("rredlist", quietly = TRUE)) {
    stop("Please install rredlist first: install.packages('rredlist')", call. = FALSE)
  }
  key <- load_iucn_key()
  invisible(key)
}
