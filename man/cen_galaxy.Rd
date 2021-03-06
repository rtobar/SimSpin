% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{cen_galaxy}
\alias{cen_galaxy}
\title{Centering the galaxy.}
\usage{
cen_galaxy(part_data)
}
\arguments{
\item{part_data}{The concatenated data frames output by \code{\link{sim_data}}.}
}
\description{
The purpose of this function is to centre the galaxy such that the origin of the
system lies at (0,0,0).
}
\examples{
  data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
  galaxy_data = rbind(data$PartType2$Part, data$PartType3$Part)

  output = cen_galaxy(part_data = galaxy_data)
}
