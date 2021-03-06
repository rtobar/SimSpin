% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/obs_imgs.R
\name{obs_imgs}
\alias{obs_imgs}
\title{Creating images from a mock IFU kinematic data cube.}
\usage{
obs_imgs(obs_data, ifu_datacube, threshold = 25, addSky = FALSE,
  mag_zero = 8.9, pixel_sscale = 0.5)
}
\arguments{
\item{obs_data}{The list output from the \code{obs_data_prep()} function.}

\item{ifu_datacube}{The list output from the function \code{\link{ifu_cube}} containing the mock
IFU cube and the apperture region image (\code{$appregion}).}

\item{threshold}{The magnitude limit of the observation in AB mag.}

\item{addSky}{A boolean to specify whether to add sky noise to the output images. Default is
FALSE. If TRUE, further parameters including \code{mag_threshold} and \code{mag_zero} described
below.}

\item{mag_zero}{The magnitude zero point with regards to the mangitude system being used (e.g.
AB or Vega).}

\item{pixel_sscale}{The corresponding spatial pixel scale associated with a given telescope
output in arcseconds.}
}
\value{
Returns a list containing:
\item{\code{$flux_img}}{The flux image produced from flattening the cube along the velocity
domain.}
\item{\code{$velocity_img}}{The line-of-sight velocity image produced from taking the flux-
weighted velocities along the velocity domain.}
\item{\code{$dispersion_img}}{The line-of-sight velocity dispersion image produced from taking
the standard deviation of the flux-weighted velocities along the velocity domain.}
\item{\code{$axis_ratio}}{A list containing the semi-major (\code{$axis_ratio$a}) and semi-minor
(\code{$axis_ratio$b}) axis lengths of the galaxy image in kpc.}
}
\description{
The purpose of this function is to construct the observational images from a mock IFU data cube.
It accepts output parameters from \code{obs_data_prep()} and \code{ifu_cube()} and returns three
images (flux, line-of-sight velocity and line-of-sight velocity dispersion).
}
\examples{
galaxy_data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
data        = obs_data_prep(simdata = galaxy_data)
fluxes      = flux_grid(obs_data = data, multi_thread=FALSE)
cube        = ifu_cube(obs_data  = data, flux_data = fluxes)
images      = obs_imgs(obs_data = data, ifu_datacube = cube)

}
