#' Read excitation-emission fluorecence matrix (eem)
#'
#' @param file File name or folder containing fluorescence file(s).
#' @param recursive logical. Should the listing recurse into directories?
#'
#' @return If \code{file} is a single filename:
#'
#'   An object of class \code{eem} containing: \itemize{ \item sample The file
#'   name of the eem. \item x A matrix with fluorescence values. \item em
#'   Emission vector of wavelengths. \item ex Excitation vector of wavelengths.
#'   }
#'
#'   If \code{file} is a folder, the function returns an object of class
#'   \code{eemlist} which is simply a list of \code{eem}.
#'
#' @details At the moment, Cary Eclipse, Aqualog and Shimadzu EEMs are
#'   supported.
#'
#'   \code{eemR} will automatically try to determine from which
#'   spectrofluorometer the files originate and load the data accordingly. Note
#'   that EEMs are reshaped so X[1, 1] represents the fluoresence intensity at
#'   X[min(ex), min(em)].
#'
#' @importFrom stats na.omit
#' @importFrom readr read_lines
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)

eem_read <- function(file, recursive = FALSE) {

  stopifnot(file.exists(file) | file.info(file)$isdir,
            is.logical(recursive))

  #--------------------------------------------
  # Verify if user provided a dir or a file.
  #--------------------------------------------
  isdir <- file.info(file)$isdir

  if(isdir){

    files <- list.files(file,
                        full.names = TRUE,
                        recursive = recursive,
                        no.. = TRUE,
                        include.dirs = FALSE,
                        pattern = "*.txt|*.dat|*.csv",
                        ignore.case = TRUE)

    files <- files[!file.info(files)$isdir]

    res <- lapply(files, eem_read)

    #res <- lapply(res, my_unlist)
    #res <- unlist(res, recursive = FALSE)

    class(res) <- "eemlist"

    res[unlist(lapply(res, is.null))] <- NULL ## Remove unreadable EEMs

    return(res)
  }

  #---------------------------------------------------------------------
  # Read the file and try to figure from which spectrofluo it belongs.
  #---------------------------------------------------------------------
  #data <- readLines(file)

  data <- read_lines(file)

  if(is_cary_eclipse(data)){
    return(eem_read_cary(data, file))
  }

  if(is_aqualog(data)){
    return(eem_read_aqualog(data, file))
  }

  if(is_shimadzu(data)){
    return(eem_read_shimadzu(data, file))
  }

  message("I do not know how to read *** ", basename(file), " ***\n")

  return(NULL)

}

#' eem constructor
#'
#' @param sample A string containing the file name of the eem.
#' @param x A matrix with fluorescence values.
#' @param ex Vector of excitation wavelengths.
#' @param em Vector of emission wavelengths.
#'
#' @importFrom tools file_path_sans_ext
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The file name of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }

eem <- function(sample, x, ex, em){

  eem <- list(sample = make.names(file_path_sans_ext(basename(sample))),
              x = x,
              ex = ex,
              em = em)

  class(eem) <- "eem"

  return(eem)
}


is_cary_eclipse <- function(x) {
  any(grepl("EX_", x)) ## Need to be more robust
}

is_aqualog <- function(x) {
  any(grepl("Normalized by|^Sample - Blank|^Wavelength", x))
}

is_shimadzu <- function(x){

  x <- stringr::str_split(x, "\t")

  # a bit weak, but works for now
  all(unlist(lapply(x, length)) %in% 2)
}

#---------------------------------------------------------------------
# Function reading Shimadzu .TXT files.
#---------------------------------------------------------------------
eem_read_shimadzu <- function(data, file){

  data <- stringr::str_split(data, "\t")

  data <- lapply(data, as.numeric)

  data <- do.call(rbind, data)

  min_em <- min(data[, 1])
  max_em <- max(data[, 1])

  interval <- data[2, 1] - data[1, 1]

  em <- seq(min_em, max_em, by = interval)

  data <- data[, 2]

  eem <- matrix(data, nrow = length(em), byrow = FALSE)

  ## Construct an eem object.
  res <- eem(sample = file,
             x = eem,
             ex = NA,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manucafturer") <- "Shimadzu"

  message("Shimadzu files do not contain excitation wavelengths.")
  message("Please provide them using the eem_set_wavelengths() function.")

  return(res)

}

#---------------------------------------------------------------------
# Function reading Cary Eclipse csv files.
#---------------------------------------------------------------------
eem_read_cary <- function(data, file){

  data <- stringr::str_split(data, ",")

  ## Find the probable number of columns
  expected_col <- length(data[[1]])

  data[lapply(data, length) != expected_col] <- NULL

  ex <- as.numeric(na.omit(stringr::str_match(data[[1]],
                                              "EX_(\\d{3}.\\d{2})")[, 2]))

  data[1:2] <- NULL ## Remove the first 2 header lines

  data <- matrix(as.numeric(unlist(data, use.names = FALSE)),
                 ncol = expected_col, byrow = TRUE)

  data <- data[,which(colMeans(is.na(data)) < 1)] ## remove na columns

  eem <- data[, !data[1, ] %in% ex] ## Remove duplicated columns

  em <- data[, 1]

  ## Construct an eem object.
  res <- eem(sample = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manucafturer") <- "Cary Eclipse"

  return(res)
}

#---------------------------------------------------------------------
# Fonction reading Aqualog dat files.
#---------------------------------------------------------------------
eem_read_aqualog <- function(data, file){

  data <- readr::read_delim(file, delim = "\t")
  data <- na.omit(data)

  ex <- rev(as.numeric(grep("[0-9]", names(data), value = TRUE)))
  em <- as.numeric(grep("[0-9]", t(data[, 1]), value = TRUE))

  eem <- as.matrix(data[, ncol(data): 2])

  ## Construct an eem object.
  res <- eem(sample = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manucafturer") <- "Aqualog"

  return(res)
}
