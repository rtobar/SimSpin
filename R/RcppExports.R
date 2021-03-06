# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' Centering the galaxy.
#'
#' The purpose of this function is to centre the galaxy such that the origin of the
#' system lies at (0,0,0).
#'
#' @param part_data The concatenated data frames output by \code{\link{sim_data}}.
#' @examples
#'   data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
#'   galaxy_data = rbind(data$PartType2$Part, data$PartType3$Part)
#'
#'   output = cen_galaxy(part_data = galaxy_data)
#' @export
cen_galaxy <- function(part_data) {
    .Call('_SimSpin_cen_galaxy', PACKAGE = 'SimSpin', part_data)
}

#' Constructing galaxy observation data from the Gadget output file data.
#'
#' The purpose of this function is to produce the observable features of simulation data when
#' taking mock IFU observations. It accepts particle information output from the
#' \code{\link{sim_data}} function and returns the observable galaxy properties projected at a
#' user supplied inclination.
#'
#' @param part_data The concatenated data frames output by \code{\link{sim_data}}.
#' @param inc_rad The observed inclination angle in radians.
#' @return Returns a data frame containing the original particle information plus the observed
#'  z-position (\code{$z_obs}), observed radial position (\code{$r_obs}) and the observed line of
#'  sight velocity (\code{$vy_obs}) at the given inclination.
#' @examples
#'   data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
#'   galaxy_data = rbind(data$PartType2$Part, data$PartType3$Part)
#'
#'   output = obs_galaxy(part_data = galaxy_data,
#'                       inc_rad   = 0)
#' @export
obs_galaxy <- function(part_data, inc_rad) {
    .Call('_SimSpin_obs_galaxy', PACKAGE = 'SimSpin', part_data, inc_rad)
}

#' Constructing galaxy simulation data from the Gadget output file data
#'
#' The purpose of this function is to produce the extra kinematic features for simulation data in
#' spherical polar coordinates. It accepts particle information output from the
#' \code{\link{sim_data}} function and returns several additional galaxy properties that are
#' useful for deriving the galaxy kinematics.
#'
#' @param part_data The concatenated data frames output by \code{\link{sim_data}}.
#' @param centre A logical that tells the function to centre the galaxy about its centre of mass
#'  or not (i.e. TRUE or FALSE).
#' @return Returns a data frame containing the particle \code{$ID}, \code{$x-}, \code{$y-} and
#'  \code{$z-}positions and corresponding velocities (\code{$vx, $vy } and \code{$vz}), along with
#'  the spherical polar coordinates (\code{$r}, \code{$theta} and \code{$phi}) and associated
#'  velocities (\code{$vr}, \code{$vtheta} and \code{$vphi}), the cylindrical radial coordinate
#'  and its associated velocity (\code{$cr} and \code{$vcr}) and the mass of each particle
#'  (\code{$Mass}) and their angular momentum components (\code{$Jx}, \code{$Jy},\code{$Jz}).
#' @examples
#'   data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
#'   galaxy_data = rbind(data$PartType2$Part, data$PartType3$Part)
#'
#'   output = sim_galaxy(part_data = galaxy_data,
#'                       centre    = TRUE)
#' @export
sim_galaxy <- function(part_data, centre) {
    .Call('_SimSpin_sim_galaxy', PACKAGE = 'SimSpin', part_data, centre)
}

