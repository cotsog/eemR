% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eem_correction.R
\name{eem_remove_blank}
\alias{eem_remove_blank}
\title{Blank correction}
\usage{
eem_remove_blank(eem, blank)
}
\arguments{
\item{eem}{Either an object of class \code{eem} or \code{eemlist}.}

\item{blank}{Either an object of class \code{eem} or a list of \code{eem}.}
}
\value{
Either an object of class \code{eem} or \code{eemlist}.
}
\description{
Blank correction
}
\details{
Scatter bands can often be reduced by subtracting water blank.
}
\examples{

## Example 1

# Open the fluorescence eem
file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
eem <- eem_read(file)

plot(eem)

# Open the blank eem
file <- system.file("extdata/cary/", "nano.csv", package = "eemR")
blank <- eem_read(file)

plot(blank)

# Remove the blank
eem <- eem_remove_blank(eem, blank)

plot(eem)

## Example 2

# Open the fluorescence eem
folder <- system.file("extdata/cary/eem/", package = "eemR")
eem <- eem_read(folder)

plot(eem, which = 3)

# Open the blank eem
file <- system.file("extdata/cary/", "nano.csv", package = "eemR")
blank <- eem_read(file)

plot(blank)

# Remove the blank
eem <- eem_remove_blank(eem, blank)

plot(eem, which = 3)
}
\references{
Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013).
  Fluorescence spectroscopy and multi-way techniques. PARAFAC. Analytical
  Methods, 5(23), 6557. http://doi.org/10.1039/c3ay41160e

  \url{http://xlink.rsc.org/?DOI=c3ay41160e}
}

