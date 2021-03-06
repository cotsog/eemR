% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eem_read.R
\name{eem}
\alias{eem}
\title{eem constructor}
\usage{
eem(sample, x, ex, em)
}
\arguments{
\item{sample}{A string containing the file name of the eem.}

\item{x}{A matrix with fluorescence values.}

\item{ex}{Vector of excitation wavelengths.}

\item{em}{Vector of emission wavelengths.}
}
\value{
An object of class \code{eem} containing:
\itemize{
 \item sample The file name of the eem.
 \item x A matrix with fluorescence values.
 \item em Emission vector of wavelengths.
 \item ex Excitation vector of wavelengths.
}
}
\description{
eem constructor
}

