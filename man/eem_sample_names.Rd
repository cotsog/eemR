% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eem_utils.R
\name{eem_sample_names}
\alias{eem_sample_names}
\title{The names of an eem or eemlist objects}
\usage{
eem_sample_names(eem)
}
\arguments{
\item{eem}{An object of class \code{eem} or \code{eemlist}.}
}
\value{
A character vector containing the names of the EEMs.
}
\description{
The names of an eem or eemlist objects
}
\examples{
file <- system.file("extdata/cary/eem", "sample1.csv", package = "eemR")
eem <- eem_read(file)

eem_sample_names(eem)

}

