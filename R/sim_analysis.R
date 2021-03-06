# Kate Harborne (last edit - 23/04/2018)
#'Kinematic analysis of simulation data.
#'
#'The purpose of this function is to calculate the kinematic properties of a simulated galaxy,
#' specifically the velocity and dispersion of particles within certain user defined bins. The user
#' must specify which direction they wish to study the kinematics using \code{bin_type} (where
#' \code{= "r"} specifies out radial 3D spherical bins, \code{= "cr"} specifies radial 2D circular
#' bins, and \code{= "z"} specifies directly in 1D out of the plane of the galaxy). The default,
#' \code{bin_type = "r"} will return a comprehensive list of the simulation's kinematic properties
#' (i.e. contained radial mass and densities, velocities, velocity dispersions, anisotropy,
#' rotational and circular velocities and spin parameter). Other options for \code{bin_type} will
#' not contain the anisotropy, rotational and circular velocities or spin parameter as these are
#' only physical when defined using 3D spherical shells.
#'
#'@param simdata The simulation information data.frame output by \code{\link{sim_data}}.
#'@param bin_type The direction in which to bin the simulation model - \code{"r"} (default) bins
#' radially in 3D spherical shells, \code{"cr"} bins radially in 2D circular rings, \code{"z"} bins
#' in 1D off the plane of the galaxy.
#'@param rmax The maximum radial coordinate considered within the simulated galaxy in kpc.
#'@param rbin The number of radial bins considered.
#'@param DM_profile If dark matter particles are not included in the analysis, this option allows
#' you to use the DM profile for the mass distribution such that the circular velocity can be
#' correctly determined. Options include \code{NA} (default),
#' \code{list("profile"="NFW", "DM_vm"=186.9, "DM_a"=34.5, "DM_rhof"=0.035)} - where DM_vm is the virial mass, DM_a is the
#' scale radius, and DM_rhof is the density evaluated at the flattening radius - and
#' \code{list("profile"="Hernquist", "DM_mass"=184.9, "DM_a"=34.5)} - where DM_mass is the total mass of the dark
#' matter component and DM_a is the scale radius of the halo.
#'@return A list that contains the particle data of the simulation (\code{$part_data} and \code{$head_data} for a particle data.frame and header
#'file respectively), a data frame containing kinematic features of radial bins (\code{$profile}) including (at least):
#'\item{\code{$r}/\code{$cr}/\code{$z}}{The outer radius of each bin.}
#'\item{\code{$Mass}}{The contained mass.}
#'\item{\code{$logp}}{The logarithm of the density in each bin.}
#'\item{\code{$vr}/\code{$vcr}/\code{$vz}}{The average velocities in each bin.}
#'\item{\code{$sigma_vr}/\code{$sigma_vcr}/\code{$sigma_vz}}{The average velocity dispersions in
#' each bin.}
#'\item{\code{$J}}{The angular momentum magnitude in each shell.}
#'In the case of \code{bin_type = "r"} additionally the circular velocity
#' (\code{$vc}), the velocity anisotropy (\code{$B}), rotational velocity (\code{$vrot}) and the
#' spin parameter (\code{$lambda}) are included in the output data frame. Finally, the dispersion
#' of particles off the plane of the disc is also given as \code{$sigma_z}, which describes the
#' standard deviation of particle positions about the z-axis.
#'@examples
#'  galaxy_data = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))
#'  output = sim_analysis(simdata = galaxy_data,
#'                        DM_profile = list("profile"="Hernquist", "DM_mass" = 184.9, "DM_a" = 34.5))
#'
#'  output = sim_analysis(simdata    = galaxy_data,
#'                        bin_type   = "cr",
#'                        rmax       = 300,
#'                        rbin       = 100,
#'                        DM_profile = list("profile"="Hernquist", "DM_mass" = 184.9, "DM_a" = 34.5))
#'

sim_analysis = function(simdata, bin_type="r", rmax=200, rbin=200, DM_profile=NA){

  result = grepl(paste(c("PartType0", "PartType1", "PartType2", "PartType3", "PartType4"), collapse = "|"), names(simdata))
  # finding the particles within the simulation for imaging

  if (!("PartType0" %in% names(simdata))){ # if the simulation doesn't have any DM particles
    if (is.na(DM_profile[1])){             # AND if no analytic DM_profile has been described
      cat("No dark matter component is included in this analysis. Describe an analytic potential to calculate the total kinematic profile correctly. \n")
      stop("DM Error")                     # issue error.
    }
  }

  if (any(result)) {                                       # concatenating the seperate particle
    present = which(result)                                #  data.frames into a single data.frame
    if (length(present) == 1){
      galaxy_data = simdata[[present[1]]]$Part
    } else if (length(present) == 2){
      galaxy_data = rbind(simdata[[present[1]]]$Part, simdata[[present[2]]]$Part)
    } else if (length(present) == 3){
      galaxy_data = rbind(simdata[[present[1]]]$Part, simdata[[present[2]]]$Part, simdata[[present[3]]]$Part)
    } else if (length(present) == 4){
      galaxy_data = rbind(simdata[[present[1]]]$Part, simdata[[present[2]]]$Part, simdata[[present[3]]]$Part,
                          simdata[[present[4]]]$Part)
    } else if (length(present) == 5){
      galaxy_data = rbind(simdata[[present[1]]]$Part, simdata[[present[2]]]$Part, simdata[[present[3]]]$Part,
                          simdata[[present[4]]]$Part, simdata[[present[5]]]$Part)
    }
  }

  galaxy_df  = sim_galaxy(galaxy_data, centre=TRUE)        # adding spherical coordinates and J
  grp        = matrix()                                    # empty placeholders for loops
  grp_mass   = 0
  grp_Jx     = 0
  grp_Jy     = 0
  grp_Jz     = 0
  grp_vtheta = 0
  grp_vphi   = 0
  G = 4.516e-29                                            # gravitational constant in units of kpc^3/([1e10 Msolar]s^2)

  ## For 3D spherical shells ## -------------------------------------------------------------------
  if (bin_type == "r"){
    galaxy_cdf       = galaxy_df[galaxy_df$r < rmax,]      # remove particles further than rmax (spherical)
    sigma_z          = sqrt(mean(galaxy_cdf$z * galaxy_cdf$z)-(mean(galaxy_cdf$z))^2)
    galaxy_cdf$group = as.integer(cut(galaxy_cdf$r,
                                      breaks=seq(0,rmax,by=rmax/rbin),
                                      labels=seq(1,rbin))) # assigns each particle into an rbin
    grp_num          = data.frame("rbin"   = seq(1, rmax, length.out=rbin),
                                  "Freq"   = integer(rbin),
                                  "cumsum" = integer(rbin))
                                                           # sets up DF with each radial bin and number of particles in each
    grp_obins        = as.data.frame(table(with(galaxy_cdf, group)))
                                                           # the number of particles in each occupied bin (may be shorter than rbin)
    grp_num[as.integer(levels(grp_obins$Var1)),2] = grp_obins$Freq
                                                           # putting occupied bins into the full rbin
    grp_num$cumsum   = cumsum(grp_num$Freq)                # total number of particles contained within rbin to the centre
    galaxy_odf       = galaxy_cdf[order(galaxy_cdf$group),]
                                                           # ordering particles by group
    rbin_labels      = seq(0,rmax,rmax/rbin)
    DM_mass_profile = rep(0, rbin)
    if (is.list(DM_profile)){
      if (DM_profile$profile == "Hernquist"){
        DM_mass_profile = DM_profile$DM_mass * rbin_labels[2:length(rbin_labels)]^2 / (DM_profile$DM_a + rbin_labels[2:length(rbin_labels)])^2
      } else if (DM_profile$profile == "NFW"){
        DM_mass_profile = 4 * pi * DM_profile$DM_rhof * DM_profile$DM_a^3 * (log(1 + (rbin_labels[2:length(rbin_labels)]/DM_profile$DM_a)) - ((rbin_labels[2:length(rbin_labels)]/DM_profile$DM_a) / (1 + (rbin_labels[2:length(rbin_labels)]/DM_profile$DM_a))))
      }
    }
                                                           # if a DM profile is assigned, assigning the radial mass profile
    profile = data.frame("r"        = numeric(rbin),
                         "Mass"     = numeric(rbin),
                         "logp"     = numeric(rbin),
                         "vc"       = numeric(rbin),
                         "Jx"       = numeric(rbin),
                         "Jy"       = numeric(rbin),
                         "Jz"       = numeric(rbin),
                         "J"        = numeric(rbin),
                         "vr"       = numeric(rbin),
                         "sigma_vr" = numeric(rbin),
                         "sigma_vt" = numeric(rbin),
                         "sigma2_vx" = numeric(rbin),
                         "sigma2_vz" = numeric(rbin),
                         "B"        = numeric(rbin),
                         "vrot"     = numeric(rbin),
                         "lambda"   = numeric(rbin))             # empty placeholders for output profile variables
    for (j in 1:rbin){
      if (j == 1){
        grp = galaxy_odf[as.integer(1:grp_num$cumsum[j]),]
      } else {
        grp = galaxy_odf[as.integer(grp_num$cumsum[j-1]+1):as.integer(grp_num$cumsum[j]),]
      }
                                                           # all data in an individual radius bin
      profile$r[j] = rbin_labels[j+1]                      # the outer edge of each radial bin
      grp_mass = sum(grp$Mass)                             # mass in radial bin
      if (j == 1){
        profile$Mass[j] = grp_mass
      } else {
        profile$Mass[j] = grp_mass + profile$Mass[j-1]
      }
                                                           # enclosed mass within outer radius
      profile$logp[j] =
        log10(grp_mass / ((4 / 3) * pi * ((profile$r[j] * profile$r[j] * profile$r[j]) - (rbin_labels[j] * rbin_labels[j] * rbin_labels[j]))))
                                                           # log10 of shell density
      profile$vc[j] =
        (sqrt((G  * (profile$Mass[j]+DM_mass_profile[j])) / profile$r[j])) * 3.086e16
                                                           # the circular velocity of particles at this radius, km/s
      grp_Jx = sum(grp$Jx)                                 # angular momentum components of shell
      grp_Jy = sum(grp$Jy)
      grp_Jz = sum(grp$Jz)
      grp_J  = sqrt((grp_Jx * grp_Jx) + (grp_Jy * grp_Jy) + (grp_Jz * grp_Jz))
                                                           # magnitude of angular momentum
      if (j == 1){
        profile$Jx[j] = grp_Jx
        profile$Jy[j] = grp_Jy
        profile$Jz[j] = grp_Jz
      } else {
        profile$Jx[j] = grp_Jx + profile$Jx[j-1]
        profile$Jy[j] = grp_Jy + profile$Jy[j-1]
        profile$Jz[j] = grp_Jz + profile$Jz[j-1]
      }
                                                           # enclosed angular momentum components
      profile$J[j]  = sqrt((profile$Jx[j] * profile$Jx[j]) + (profile$Jy[j] * profile$Jy[j]) + (profile$Jz[j] * profile$Jz[j]))
                                                           # enclosed magnitude of angular momentum
      profile$vr[j] = mean(grp$vr)                         # mean radial velocity in the shell, km/s
      grp_vtheta = mean(grp$vtheta)                        # mean velocity along theta in the shell, km/s
      grp_vphi   = mean(grp$vphi)                          # mean velocity along phi in the shell, km/s
      profile$sigma_vr[j] = sqrt(mean(grp$vr * grp$vr) - (profile$vr[j] * profile$vr[j]))
                                                           # radial velocity dispersion, km/s
      profile$sigma_vt[j] = sqrt((mean(grp$vtheta * grp$vtheta) - (grp_vtheta * grp_vtheta)) +
                                   (mean(grp$vphi * grp$vphi) - (grp_vphi * grp_vphi)))
                                                           # tangential velocity dispersion, km/s
      profile$sigma2_vx[j] = sum((grp$vx - mean(grp$vx))^2) / length(grp$vx)
      profile$sigma2_vz[j] = sum((grp$vz - mean(grp$vz))^2) / length(grp$vz)
      profile$B[j] = 1 - ((profile$sigma_vt[j] * profile$sigma_vt[j]) / (2 * profile$sigma_vr[j] * profile$sigma_vr[j]))
                                                           # velocity anisotropy, unitless
      profile$vrot[j] = grp_J / (grp_mass * profile$r[j] * 3.086e16)
                                                           # rotational velocity, km/s
      profile$lambda[j] = profile$J[j] / (1.414214 * profile$Mass[j] * profile$vc[j] * profile$r[j] * 3.086e16)
                                                           # spin parameter, unitless
    }
  }
  ## For 2D circular radial shells ## -------------------------------------------------------------
  if (bin_type == "cr"){
    galaxy_cdf       = galaxy_df[(galaxy_df$cr < rmax) &
                                   (abs(galaxy_df$z) < rmax),]
                                                           # remove particles further than rmax (cyclindrical)
    sigma_z          = sqrt(mean(galaxy_cdf$z * galaxy_cdf$z)-(mean(galaxy_cdf$z))^2)
    galaxy_cdf$group = as.integer(cut(galaxy_cdf$cr,
                                      breaks=seq(0,rmax,rmax/rbin),
                                      labels=seq(1,rbin))) # assigns each particle into an rbin
    grp_num          = data.frame("rbin"   = seq(1, rmax, length.out=rbin),
                                  "Freq"   = integer(rbin),
                                  "cumsum" = integer(rbin))
                                                           # sets up DF with each radial bin and number of particles in each
    grp_obins        = as.data.frame(table(with(galaxy_cdf, group)))
                                                          # the number of particles in each occupied bin (may be shorter than rbin)
    grp_num[as.integer(levels(grp_obins$Var1)),2] = grp_obins$Freq
                                                          # putting occupied bins into the full rbin
    grp_num$cumsum   = cumsum(grp_num$Freq)               # total number of particles contained within rbin to the centre
    galaxy_odf       = galaxy_cdf[order(galaxy_cdf$group),]
                                                          # ordering particles by group
    rbin_labels      = seq(0,rmax,rmax/rbin)
    profile = data.frame("cr"       = numeric(rbin),
                         "Mass"     = numeric(rbin),
                         "logp"     = numeric(rbin),
                         "J"        = numeric(rbin),
                         "Jx"       = numeric(rbin),
                         "Jy"       = numeric(rbin),
                         "Jz"       = numeric(rbin),
                         "vcr"      = numeric(rbin),
                         "sigma_vcr"= numeric(rbin))             # empty placeholders for output profile variables
    for (j in 1:rbin){
      if (j == 1){
        grp = galaxy_odf[as.integer(1:grp_num$cumsum[j]),]
      } else {
        grp = galaxy_odf[as.integer(grp_num$cumsum[j-1]+1):as.integer(grp_num$cumsum[j]),]
      }
                                                           # all data in an individual radius bin
      profile$cr[j] = rbin_labels[j+1]                     # the outer edge of each radial bin
      grp_mass = sum(grp$Mass)                             # mass in radial bin
      if (j == 1){
        profile$Mass[j] = grp_mass
      } else {
        profile$Mass[j] = grp_mass + profile$Mass[j-1]
      }
                                                            # enclosed mass within outer radius
      profile$logp[j] =
        log10(grp_mass / (pi * 2 * rmax * ((profile$cr[j] * profile$cr[j]) - (rbin_labels[j] * rbin_labels[j]))))
                                                            # log10 of shell density
      grp_Jx = sum(grp$Jx)                                  # angular momentum components of shell
      grp_Jy = sum(grp$Jy)
      grp_Jz = sum(grp$Jz)
      grp_J  = sqrt((grp_Jx * grp_Jx) + (grp_Jy * grp_Jy) + (grp_Jz * grp_Jz))
                                                            # magnitude of angular momentum
      if (j == 1){
        profile$Jx[j] = grp_Jx
        profile$Jy[j] = grp_Jy
        profile$Jz[j] = grp_Jz
      } else {
        profile$Jx[j] = grp_Jx + profile$Jx[j-1]
        profile$Jy[j] = grp_Jy + profile$Jy[j-1]
        profile$Jz[j] = grp_Jz + profile$Jz[j-1]
      }
                                                             # enclosed angular momentum components
      profile$J[j]  = sqrt((profile$Jx[j] * profile$Jx[j]) + (profile$Jy[j] * profile$Jy[j]) + (profile$Jz[j] * profile$Jz[j]))
                                                             # enclosed magnitude of the angular momentum
      profile$vcr[j] = mean(grp$vcr)                         #  mean radial velocity in the shell, km/s
      profile$sigma_vcr[j] = sqrt(mean(grp$vcr * grp$vcr) - (profile$vcr[j] * profile$vcr[j]))
                                                             # radial velocity dispersion, (km/s)
    }
  }
  ## For 2D circular planar shells ## -------------------------------------------------------------
  if (bin_type == "z"){
    galaxy_cdf       = galaxy_df[(galaxy_df$cr < rmax) &
                                   ((galaxy_df$z) < rmax) &
                                   ((galaxy_df$z) > 0),]    # remove particles further than rmax (off surface of disk) and below 0
    sigma_z          = sqrt(mean(galaxy_cdf$z * galaxy_cdf$z)-(mean(galaxy_cdf$z))^2)
    galaxy_cdf$group = as.integer(cut(galaxy_cdf$z,
                                      breaks=seq(0,rmax,rmax/rbin),
                                      labels=seq(1,rbin)))  # assigns each particle into an rbin
    grp_num          = data.frame("rbin"   = seq(1, rmax, length.out=rbin),
                                  "Freq"   = integer(rbin),
                                  "cumsum" = integer(rbin)) # sets up DF with each radial bin and number of particles in each
    grp_obins        = as.data.frame(table(with(galaxy_cdf, group)))
                                                            # the number of particles in each occupied bin (may be shorter than rbin)
    grp_num[as.integer(levels(grp_obins$Var1)),2] = grp_obins$Freq
                                                            # putting occupied bins into the full rbin
    grp_num$cumsum   = cumsum(grp_num$Freq)                 # total number of particles contained within rbin to the centre
    galaxy_odf       = galaxy_cdf[order(galaxy_cdf$group),] # ordering particles by group
    zbinsize         = rmax/rbin
    rbin_labels      = seq(0,rmax,zbinsize)
    profile = data.frame("z"       = numeric(rbin),
                         "Mass"    = numeric(rbin),
                         "logp"    = numeric(rbin),
                         "J"       = numeric(rbin),
                         "Jx"      = numeric(rbin),
                         "Jy"      = numeric(rbin),
                         "Jz"      = numeric(rbin),
                         "vz"      = numeric(rbin),
                         "sigma_vz"= numeric(rbin))              # empty placeholders for output profile variables
    for (j in 1:rbin){
      if (j == 1){
        grp = galaxy_odf[as.integer(1:grp_num$cumsum[j]),]
      } else {
        grp = galaxy_odf[as.integer(grp_num$cumsum[j-1]+1):as.integer(grp_num$cumsum[j]),]
      }
                                                           # all data in an individual radius bin
      profile$z[j] = rbin_labels[j+1]                      # the outer edge of each radial bin
      grp_mass = sum(grp$Mass)                             # mass in radial bin
      if (j == 1){
        profile$Mass[j] = grp_mass
      } else {
        profile$Mass[j] = grp_mass + profile$Mass[j-1]
      }
                                                           # enclosed mass within outer radius
      profile$logp[j] =
        log10(grp_mass / (pi * rmax * rmax * (profile$z[j]  -  rbin_labels[j])))
                                                           # log10 of shell density
      grp_Jx = sum(grp$Jx)                                 # angular momentum components of shell
      grp_Jy = sum(grp$Jy)
      grp_Jz = sum(grp$Jz)
      grp_J  = sqrt((grp_Jx * grp_Jx) + (grp_Jy * grp_Jy) + (grp_Jz * grp_Jz))
                                                           # magnitude of angular momentum
      if (j == 1){
        profile$Jx[j] = grp_Jx
        profile$Jy[j] = grp_Jy
        profile$Jz[j] = grp_Jz
      } else {
        profile$Jx[j] = grp_Jx + profile$Jx[j-1]
        profile$Jy[j] = grp_Jy + profile$Jy[j-1]
        profile$Jz[j] = grp_Jz + profile$Jz[j-1]
      }
                                                            # enclosed angular momentum components
      profile$J[j]  = sqrt((profile$Jx[j] * profile$Jx[j]) + (profile$Jy[j] * profile$Jy[j]) + (profile$Jz[j] * profile$Jz[j]))
                                                            # enclosed magnitude of the angular momentum
      profile$vz[j] = mean(grp$vz)                          # mean radial velocity in the shell, km/s
      profile$sigma_vz[j] = sqrt(mean(grp$vz * grp$vz) - (profile$vz[j] * profile$vz[j]))
                                                            # radial velocity dispersion, km/s
    }
  }

  return(list("part_data" = galaxy_data, "profile" = profile, "sigma_z" = sigma_z))
}
