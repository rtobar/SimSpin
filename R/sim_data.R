# Kate Harborne (last edit - 03/12/2018)
#'Prepare simulation data for SimSpin
#'
#'The purpose of this function is to take a SimSpin simulation file (an HDF5 file with particle
#' information subset in particle types, "PartTypeX") and output a data.frame that is easy for
#' processing throughout the rest of the package. This reduces the number of times that you need to
#' load the simulation into the package, which is the most time-consuming process. This also allows
#' you to combine the particle information with spectral information output from other codes.
#'
#'@param filename The SimSpin HDF5 file containing the particle information of the galaxy.
#'@param ptype The particle type/types to be extracted - NA (default) gives all particles in the
#' simulation, 0 - gas, 1 - dark matter, 2 - disc, 3 - bulge, 4 - stars, 5 - boundary.
#'@param SSP The spectral information HDF5 file containing the luminosities for each particle at
#' each wavelength.
#'@param m2l_disc The mass-to-light ratio of the disc component in solar units.
#'@param m2l_bulge The mass-to-light ratio of the bulge component in solar units.
#'@param m2l_star If no SSP file is specified and stellar particles exist in the file, the
#' mass-to-light ratio of the stellar component in solar units.
#'
#'@return A list of data.frames containing the particle information (\code{$Part}) for each
#' particle type requested from the simulation. Each data frame contains the position (x, y, z)
#' and velocity (vx, vy, vz) information, along with the ID and mass of each particle. Also
#' associated with each PartType element in the list is an array of luminosities, \code{$Lum}. If
#' SSP information has been supplied, this will be a 2D array with a second wavelength array
#' (\code{$Wav}) specifying the wavelength at which each luminosity is defined. Else, a single
#' luminosity will be associated with each particle.
#'@examples
#' output = sim_data(system.file("extdata", 'SimSpin_example.hdf5', package="SimSpin"))

sim_data = function(filename, ptype=NA, SSP=NA, m2l_disc=1, m2l_bulge=1, m2l_star=1){

  galaxy_file = hdf5r::h5file(filename, mode = "r")           # reading in the snapshot data
  ppart = substring(hdf5r::list.groups(galaxy_file), 1)
  if (is.na(ptype[1])){
    ptype = ppart # if NA is chosen, extract all present particle types
  } else {
    ptype = paste("PartType", as.character(ptype), sep="")
    # else convert ptype into a comparible format
    if (!all(ptype %in% ppart)){ # if any requested particle types are not within the file
      cat("Particles of", paste(ptype[!ptype %in% ppart], collapse = ","), "are missing in this model. \n")
      stop("Npart Error")
    }
  }

  if ("PartType0" %in% ptype){ # if gas particles are requested
    gas_n = length(hdf5r::readDataSet(galaxy_file[["PartType0/x"]]))
    gas_ID = formatC(1:gas_n, width = floor(log10(gas_n)) + 1, format = "d", flag = "0")
    gas_part = data.frame("ID"        = as.integer(paste0("9", gas_ID)),
                          "x"         = hdf5r::readDataSet(galaxy_file[["PartType0/x"]]),
                          "y"         = hdf5r::readDataSet(galaxy_file[["PartType0/y"]]),
                          "z"         = hdf5r::readDataSet(galaxy_file[["PartType0/z"]]),
                          "vx"        = hdf5r::readDataSet(galaxy_file[["PartType0/vx"]]),
                          "vy"        = hdf5r::readDataSet(galaxy_file[["PartType0/vy"]]),
                          "vz"        = hdf5r::readDataSet(galaxy_file[["PartType0/vz"]]),
                          "Mass"      = hdf5r::readDataSet(galaxy_file[["PartType0/Mass"]]))
    PartType0 = list("Part" = gas_part)
  }

  if ("PartType1" %in% ptype){ # if DM particles are requested
    DM_n = length(hdf5r::readDataSet(galaxy_file[["PartType1/x"]]))
    DM_ID = formatC(1:DM_n, width = floor(log10(DM_n)) + 1, format = "d", flag = "0")
    DM_part = data.frame("ID"        = as.integer(paste0("1", DM_ID)),
                         "x"         = hdf5r::readDataSet(galaxy_file[["PartType1/x"]]),
                         "y"         = hdf5r::readDataSet(galaxy_file[["PartType1/y"]]),
                         "z"         = hdf5r::readDataSet(galaxy_file[["PartType1/z"]]),
                         "vx"        = hdf5r::readDataSet(galaxy_file[["PartType1/vx"]]),
                         "vy"        = hdf5r::readDataSet(galaxy_file[["PartType1/vy"]]),
                         "vz"        = hdf5r::readDataSet(galaxy_file[["PartType1/vz"]]),
                         "Mass"      = hdf5r::readDataSet(galaxy_file[["PartType1/Mass"]]))
    PartType1 = list("Part" = DM_part)
  }

  if ("PartType2" %in% ptype){ # if disc particles are requested
    disc_n = length(hdf5r::readDataSet(galaxy_file[["PartType2/x"]]))
    disc_ID = formatC(1:disc_n, width = floor(log10(disc_n)) + 1, format = "d", flag = "0")
    disc_part = data.frame("ID"        = as.integer(paste0("2", disc_ID)),
                           "x"         = hdf5r::readDataSet(galaxy_file[["PartType2/x"]]),
                           "y"         = hdf5r::readDataSet(galaxy_file[["PartType2/y"]]),
                           "z"         = hdf5r::readDataSet(galaxy_file[["PartType2/z"]]),
                           "vx"        = hdf5r::readDataSet(galaxy_file[["PartType2/vx"]]),
                           "vy"        = hdf5r::readDataSet(galaxy_file[["PartType2/vy"]]),
                           "vz"        = hdf5r::readDataSet(galaxy_file[["PartType2/vz"]]),
                           "Mass"      = hdf5r::readDataSet(galaxy_file[["PartType2/Mass"]]))
    disc_lum = (disc_part$Mass * 1e10) / m2l_disc
    PartType2 = list("Part" = disc_part, "Lum" = disc_lum)

  }

  if ("PartType3" %in% ptype){ # if bulge particles are requested
    bulge_n = length(hdf5r::readDataSet(galaxy_file[["PartType3/x"]]))
    bulge_ID = formatC(1:bulge_n, width = floor(log10(bulge_n)) + 1, format = "d", flag = "0")
    bulge_part = data.frame("ID"        = as.integer(paste0("3", bulge_ID)),
                            "x"         = hdf5r::readDataSet(galaxy_file[["PartType3/x"]]),
                            "y"         = hdf5r::readDataSet(galaxy_file[["PartType3/y"]]),
                            "z"         = hdf5r::readDataSet(galaxy_file[["PartType3/z"]]),
                            "vx"        = hdf5r::readDataSet(galaxy_file[["PartType3/vx"]]),
                            "vy"        = hdf5r::readDataSet(galaxy_file[["PartType3/vy"]]),
                            "vz"        = hdf5r::readDataSet(galaxy_file[["PartType3/vz"]]),
                            "Mass"      = hdf5r::readDataSet(galaxy_file[["PartType3/Mass"]]))
    bulge_lum = (bulge_part$Mass * 1e10) / m2l_bulge
    PartType3 = list("Part" = bulge_part, "Lum" = bulge_lum)

  }

  if ("PartType4" %in% ptype){ # if stellar particles are requested
    star_n = length(hdf5r::readDataSet(galaxy_file[["PartType4/x"]]))
    star_ID = formatC(1:star_n, width = floor(log10(star_n)) + 1, format = "d", flag = "0")
    star_part = data.frame("ID"        = as.integer(paste0("4", star_ID)),
                           "x"         = hdf5r::readDataSet(galaxy_file[["PartType4/x"]]),
                           "y"         = hdf5r::readDataSet(galaxy_file[["PartType4/y"]]),
                           "z"         = hdf5r::readDataSet(galaxy_file[["PartType4/z"]]),
                           "vx"        = hdf5r::readDataSet(galaxy_file[["PartType4/vx"]]),
                           "vy"        = hdf5r::readDataSet(galaxy_file[["PartType4/vy"]]),
                           "vz"        = hdf5r::readDataSet(galaxy_file[["PartType4/vz"]]),
                           "Mass"      = hdf5r::readDataSet(galaxy_file[["PartType4/Mass"]]))

    if (!is.na(SSP)){ # if spectral information is supplied
      f = hdf5r::h5file(SSP, mode = "r")
      star_lum = hdf5r::readDataSet(f[["PartType4/Luminosity"]])
      star_wave = hdf5r::readDataSet(f[["PartType4/Wavelength"]])
      hdf5r::h5close(f)
      PartType4 = list("Part" = star_part, "Lum" = star_lum, "Wav" = star_wave)
    } else {
      star_lum = ((star_part$Mass * 1e10) / m2l_star)
      PartType4 = list("Part" = star_part, "Lum" = star_lum)
    }
  }

  hdf5r::h5close(galaxy_file)                                 # close the snapshot data file

  galaxy_data = setNames(lapply(ls(pattern="PartType*"), function(x) get(x)), ls(pattern="PartType*"))

  return(galaxy_data)
}