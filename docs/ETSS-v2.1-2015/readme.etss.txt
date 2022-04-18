##########################################################
# Explanation of the files in the directory:
##########################################################
   readme.etss.txt: 

##########################################################
# Explanation of the subdirectories
##########################################################
  ------------------ dev: MDL test directory ---------------------

  ./cronjob: Cronjob scripts to schedule a crontab job to test model
  ./dbnet: Fake dbnet directory. The intent is to allow the script to 
           "call" dbn_alert in test mode without actaully invoking dbn_alert.
  ./myEcf/jetss.ecf : The bsub commands used to kick off the
                              : exetss.sh.ecf script at ./scripts/folder in a
                              : a 14 thread environment to run ETSS2.1 model.
  ./myEcf/jetss_gempak_*.ecf  : The bsub commands used to kick off the
                              : exetss_nawips.sh.ecf script at ./scripts/folder
                              : to run gempak script in CONUS/ALA region.
  ./myScripts: Post-processing scripts for MDL
  .runETSS.sh: Run the ETSS model with live data copied from the /com to the 
               ./work subfolder
  .runETSS_gempak.sh: Run gempak post-processing script to generate files for OPC
  ./setup: Directory contains some scripts to set up test environment and copy data
  ./work: Directory used for testing against live output from WCOSS

  ------------------ docs: documents directory------------------
  Contains documents folder to hold the update information 

  ------------------ ecf: SPA's ecflow commands files --------------
  Contains scripts to submit job to run the ETSS model and post-processing by SPA 

  ------------------ exec: Executable code --------------------------
  ./exec/mdl_cy_puv10* : The program to extract current and future winds
  ./exec/mdl_c10_gen* : The program to extract past wind predictions.
  ./exec/mdl_ext_6h* : The actual model.  
  ./exec/mdl_mdlsurge* : The program that generates the text messages.
  ./exec/mdl_gridmerge* : The program that generates the GRIB files. 

  ------------------ jobs: Executable code --------------------------
  ./jobs/JETSS : Job card for ETSS.
  ./jobs/JETSS_GEMPAK : Job card for gempak post-processing.

  ------------------ parm: Data Sets ----------------------
  ./parm/mdl_etalaska_etss2.1.bin : The masks used for merging 3km Alaska basins (merging two extra tropical basins)
  ./parm/mdl_etalaska_etss2.1_6km.bin : The masks used for merging 6km Alaska basins (merging two extra tropical basins)
  ./parm/mdl_etconus_etss2.1.bin : The masks used for merging 2.5km CONUS basins (merge extra tropical basins and tropical basins)
  ./parm/mdl_etconus_etss2.1_5km.bin : The masks used for merging 5km CONUS basins (merge extra tropical basins and tropical basins)
  ./parm/mdl_etconus_etss2.1_625m.bin : The masks used for merging 625m CONUS basins (merge extra tropical basins and tropical basins)
  ./parm/mdl_etgrids.ala : The grid dimmensions to help merge AK basins
  ./parm/mdl_etgrids.con : The grid dimmensions to help merge CONUS basins
  ./parm/mask_f.txt : The parameter to control which tropical basins will be used to merege into the COUNS grid
  ./parm/mdl_ettgp.* : The interesting points for * = extra tropical and tropical basins
                    : These are the tidal guage point locations.
  ./parm/mdl_ft01.ega : Used by mdl_ext_6h to determine how many hours past
                    : and future.
  ./parm/mdl_ft11.* : The header information for * = extra tropical and tropical basins
                    : This is used to generate the first 2 lines in the 
                    : outgoing message from mdl_mdlsurge.
  ./parm/mdl_ft11.egawz : Contains the grid specs for each basin to help with
                    : extracting the winds in
                    : mdl_cy_puv10 and mdl_c10_gen
  ./parm/outer_ij_inner_boun_slosh*.txt : The nesting boundary locations in the extra tropical basins
  ./parm/dta : The folder holding the tropical basins dta files
  ./parm/bnt : The folder holding the tropical basins bnt files
  ./parm/trkfiles : The folder holding the fake track files, which provides track information needed by rex files
  ./parm/tidefile.ec2014 : The folder holding the tidal database, which provides tide forcing needed by ETSS model

  ------------------ scripts --------------------------------------
  ./scripts/exetss.sh.ecf : The execute script to run the model
  ./scripts/exetss_nawips.sh.ecf : The execute script to run the gempak post-processing


  ------------------ sorc: Source code --------------------------
  ./sorc/mdl_cy_puv10.fd : The program to extract current and future winds for 6 basins at one time
  ./sorc/mdl_cy_puv10_add.fd : The program to extract current and future winds for 7 basins at one time
  ./sorc/mdl_c10_gen.fd : The program to extract past wind predictions for 6 basins at one time.
  ./sorc/mdl_c10_gen_add.fd : The program to extract past wind predictions for 7 basins at one time.
  ./sorc/mdl_ext_6h.fd : The actual model to handle 37 tide constituents.  
  ./sorc/mdl_ext_6h_13tide.fd : The actual model to handle 13 tide constituents.  
  ./sorc/mdl_mdlsurge.fd : The program that generates the text messages.
  ./sorc/mdl_gridmerge.fd : The program that generates the GRIB files from extra-tropical basins only.
  ./sorc/mdl_gridmerge_nest.fd : The program that generates the GRIB files from extra-tropical and tropical basins.

  ------------------ ush --------------------------------------
  ./ush/gfs_stormsurge_poe.sh : The script to run extra tropical basins through the model by 14 cpus.  
  ./ush/gfs_stormsurge_nest_poe.sh : The script to run tropical basins through the model by 14 cpus
  ./ush/form_ntc.pl : The script to generate the forecast bulletins for station output text prodcuts


##########################################################
# Explanation of the expected output
##########################################################
  Located in:
  ./dev/tmp/com/etss/prod/etss.${date}

  ./cylf10.${cyc}${rgn} : The hindcast GFS wind field 
  ./gfspuv.${cyc}${rgn} : The current GFS wind field analysis
  ./etss.t{cyc}z.stormtide.con2p5km.grib2 : The 2.5km CONUS GRIB2 files for surge plus tide (with WMO headers)
  ./etss.t{cyc}z.stormsurge.con2p5km.grib2 : The 2.5km CONUS GRIB2 files for surge only (with WMO headers)
  ./etss.t{cyc}z.stormtide.con625m.grib2 : The 625m CONUS GRIB2 files for surge plus tide (no WMO headers)
  ./etss.t{cyc}z.stormtide.ala3km.grib2 : The 3km ALA GRIB2 files for surge plus tide (with WMO headers)
  ./etss.t{cyc}z.stormsurge.ala3km.grib2 : The 3km ALA GRIB2 files for surge only (with WMO headers)
  ./mdlsurge.${cyc}${rgn} : The predicted surge in text form 
  ./etss.t${cyc}z.stormsurge.${rgn}.txt : The predicted surge in text form in new locations
  ./etss.t${cyc}z.stormtide.${rgn}.txt : The predicted surge plus tide in text form in new locations
  ./sds.${cyc} : Any errors that occured in a given cycle 
  ./sshistory.${cyc}${rgn}* : The predicted surge at a station (in binary form)
