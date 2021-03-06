% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{obs_galaxy}
\alias{obs_galaxy}
\title{Constructing galaxy observation data from the Gadget output file data.}
\usage{
obs_galaxy(part_data, inc_rad)
}
\arguments{
\item{part_data}{The concatenated data frames output by \code{\link{sim_data}}.}

\item{inc_rad}{The observed inclination angle in radians.}
}
\value{
Returns a data frame containing the original particle information plus the observed
 z-position (\code{$z_obs}), observed radial position (\code{$r_obs}) and the observed line of
 sight velocity (\code{$vy_obs}) at the given inclination.
}
\description{
The purpose of this function is to produce the observable features of simulation data when
taking mock IFU observations. It accepts particle information output from the
\code{\link{sim_data}} function and returns the observable galaxy properties projected at a
user supplied inclination.
}
\examples{
  data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
  galaxy_data = rbind(data$PartType2$Part, data$PartType3$Part)

  output = obs_galaxy(part_data = galaxy_data,
                      inc_rad   = 0)
}
