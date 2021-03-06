% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sim_FITSimage.R
\name{sim_FITSimage}
\alias{sim_FITSimage}
\title{Generate a FITS file for the data cube produced in SimSpin}
\usage{
sim_FITSimage(out_image, out_data, z, pixel_sscale, psf_fwhm = 0,
  r200 = 200, r50 = 10, Hdisk = 5.64, Ahalo = 34.5,
  Abulge = 3.45, out_file, obs_name = "SimSpin datacube",
  addSky = FALSE, threshold = 25, mag_zero = 8.9)
}
\arguments{
\item{out_image}{The counts/velocity/dispersion image output from \code{\link{find_kinematics}}
that you wish to save.}

\item{out_data}{The list output from \code{\link{build_datacube}}, or
\code{\link{find_kinematics}}.}

\item{z}{The redshift projected distance at which
\code{\link{find_kinematics}} was run.}

\item{pixel_sscale}{The corresponding spatial pixel scale associated with a given telescope
output in arcseconds.}

\item{psf_fwhm}{The FWHM of the PSF used for spatial blurring used when
\code{\link{find_kinematics}} was run.}

\item{r200}{The virial radius specified in the simulation, kpc.}

\item{r50}{The half mass radius specified by the simulation, kpc.}

\item{Hdisk}{The scale length of the disk component in the simulation, kpc.}

\item{Ahalo}{The scale height of the dark matter halo component in the simulation, kpc.}

\item{Abulge}{The scale height of the bulge component in the simulation, kpc.}

\item{out_file}{A string describing the path and file name of the FITS file to be written.}

\item{obs_name}{A string that describes the name of the observation. Default is "SimSpin
datacube".}

\item{addSky}{A boolean to specify whether to add sky noise to the output images. Default is
FALSE. If TRUE, further parameters including \code{mag_threshold} and \code{mag_zero} described
below.}

\item{threshold}{The magnitude limit of the observation.}

\item{mag_zero}{The magnitude zero point with regards to the mangitude system being used (e.g.
AB or Vega).}
}
\value{
Outputs a standard format FITS file.
}
\description{
The purpose of this function is to write out the data cube produced by SimSpin into the common
astronomy FITS data format.
}
\examples{
galaxy_data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
kin = find_kinematics(simdata      = galaxy_data,
                      r200         = 200,
                      z            = 0.1,
                      fov          = 15,
                      ap_shape     = "circular",
                      central_wvl  = 4800,
                      lsf_fwhm     = 2.65,
                      pixel_sscale = 0.5,
                      pixel_vscale = 1.04,
                      inc_deg      = 0,
                      threshold    = 25,
                      measure_type = list(type = "fixed",
                                          axis_ratio = data.frame("a"=3.5,
                                                                  "b"=1.7,
                                                                  "angle"=90),
                                          fac = 1),
                      IFU_plot     = FALSE,
                      multi_thread = FALSE)
sim_FITSimage(out_image = kin$counts_img, out_data = kin, z = 0.1, pixel_sscale = 0.5,
out_file = "simdata_example.fits")
unlink("simdata_example.fits")
}
