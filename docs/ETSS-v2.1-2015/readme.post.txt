General process:
	SLOSH surge forecasts in text format and COOPS NCEP BUFR files are 
        parsed to obtain water level obs and surge guidance for individual 
        COOPS tide stations. Tides are also predicted for each station using 
        tide prediction equations (from xTide software) and known constituents 
        (from COOPS; where available). These data (tide, surge, and obs) are 
        then converted into a grid of integers which has the same number of 
        columns as there are stations, and the same number of rows as there 
        are time stamps. So GRID(10,63) would give the integer-ized surge, 
        tide or obs data point at time stamp 10 and station 63. This is an 
        easy-to-parse way to cheaply store the data. Time stamps are in 
        6-minute intervals spanning from 5 days before the forecast to 4 days 
        in the future. Data are given in MLLW. Station metadata are in 
        parm/master.csv. The FORTRAN code reads master.csv to get station data, 
        so the order stations are presented in master.csv is the order they are 
        presented in the output grids. Once all grids are created, combAll 
        calculates anomalies and total water level predictions, creates grids 
        for those two parameters (for a total of five grids; surge, tide, obs, 
        anom, and twl), and makes output SHEF and .csv files to be sent to /com 
        and /pcom directories.

**********************************************
EXEC DIRECTORY
**********************************************
Sub-directories:
	None

Description:
	Contains executables combAll, debufr, obsAll, surgeAll, and
	tideAll.

	combAll:  Combines surge forecast, tide prediction, and water level obs
	          into SHEF-encoded and csv output files for all stations.
		  This is the last executable called.
	debufr:   Reads in raw BUFR files from NCEP BUFR tanks and parses out
	          water level obs. This is the first executable called.
	obsAll:   Called after debufr. Further parses BUFR data and stores in a
	          format combAll can read later
	surgeAll: Parses surge forecast data and stores in a format combAll 
                  can read later
	tideAll:  Predicts tides at each station and stores tide data in format
	          that combAll can read later

**********************************************
JOBS DIRECTORY
**********************************************
Sub-directories:
        None
------------

Description:
	A collection of routines that set environmental variables for the LSF
	jobs and scripts that they kick off. Each routine also sets up a test
	environment for the SPA, should they so desire.

	JETSS_KICKOFF:  The first routine which calls scripts/exetss_kickoff.sh
 	                   to grab raw obs data and kick off ECF scripts, which in 
                           turn call the other 'JETSS' jobs in this directory
	JETSS_PARSEDAT: Second routine that calls scripts/exetss_parsedat.sh to
	                   debufr raw obs data
	JETSS_GRIDDAT:  Third routine that calls scripts/exetss_griddat.sh to
	                   execute obsAll, surgeAll, and tideAll and create
	                   interger-ized grids
	JETSS_COMBDAT:  Last routine which calls scripts/exetss_combdat.sh to
	                   execute combAll,output DBNet alert, and transfer output files

**********************************************
LIB DIRECTORY
**********************************************
Sub-directories:
	sorc: Source for the tide and mybufr libraries
-------------
             |
             |
	     mybufr: obs/mybufr library
             ---------
             |
             |
	     tide: tide library
             ----------

Description:
	Contains source code and makefiles for obs (mybufr) and tide
	libraries. Output libraries are installed here (all .a files) and
	grabbed by the main Makefile under ./sorc

	sorc/mybufr: Contains a modified version of BUFRLib v10.2.3 which only
	          returns water level obs from SHEF-encoded COOPS output in BUFR 
                  form. This is only a custom version of the original library!
	sorc/tide: A custom tide library based off of the original TCL version
	           on Slosh. Uses the same equations and parameters to calculate
	           tides using primary constituents from COOPS. Also
	           calculates tides at secondary stations already supported by
	           ETSurge1.0 product. Constituents are in parm/tide/constits
        libtide.a: The compiled tide library
	libmybufr.a: The compiled obs/custom BUFR library

**********************************************
ECF DIRECTORY
**********************************************
Sub-directories:
	None

Description:
	Home of all calls to ECF. This is where the jobs for
	parsedat, griddat, and combdat are set off. JETSS_KICKOFF calls
	exetsurge_kickoff.sh, which calls these ECF scripts. These, in turn, call the
	other jobs (like JETSS_PARSEDAT), which pull from other scripts to
	set off the executables. Set ECF settings here (like run time, number
	of CPU, etc.

	jetss_parsedat.ecf: Calls ./jobs/JETSS_PARSEDAT
	jetss_griddat.ecf: Calls ./jobs/JETSS_GRIDDAT
	jetss_combdat.ecf: Calls ./jobs/JETSS_COMBDAT


**********************************************
COM/OUT DIRECTORY
**********************************************

Description:
	Output csv files go here. They are labeled by COOPS ID and each one
        represents output for a COOPS station.


**********************************************
COM/SHEF DIRECTORY
**********************************************

Description:
	Output SHEF files go here. They are labeled by basin ('TWE',etc)
        and forecast cycle.


**********************************************
PARM DIRECTORY
**********************************************
Sub-directories:
        tide: This contains the tide constituents (in 'constits' dir) and
------------- reordFT03.csv, which the tide lib uses to get yearly constants 
	      in the correct order for calculations.

Description:
	This contains all the parameter files needed by the executables. These
	parameter files never change and are needed every time the code is
	run, so they don't belong in the tmp directory.

        master.csv: Do not edit this file if you don't know what you're
	            doing!! The executables need this program to determine how
	            many stations there are, which in turn determines the
	            grids' dimensions and how they are parsed. Master.csv also
	            contains important information needed by the code to parse
	            BUFR files, calculate tides, and probe for surge
	            forecasts. Always keep a back-up copy of this. A readme in
                    parm gives more details...

**********************************************
SCRIPTS DIRECTORY
**********************************************
Sub-directories:
	None

Description:
	Jobs in the ./jobs directory call these scripts, which in turn call
	ecf scripts, and/or executables. Some scripts here are just
	utilities to grab data

	exetss_parsedat.sh.ecf: Creates poescripts to debufr obs data in parallel 
                                Also creates list of date-based filenames for
	                        executable code to read and places that in ./tmpnwprd1.
	exetss_griddat.sh.ecf:  Creates poescript to run the executables obsAll, surgeAll,
	                        and tideAll in parallel
	exetss_combdat.sh.ecf:  Runs the combAll executable, transfers output
                                SHEF to COM, and sends out DBNet alert

**********************************************
SORC DIRECTORY
**********************************************
Sub-directories:
	combAll.fd: Contains source code and makefile for combAll executable
--------------------
                    |
                    |
	debufr.fd: Contains source code and makefile for combAll executable
--------------------
                    |
                    |
	obsAll.fd: Contains source code and makefile for obsAll executable
--------------------
                    |
                    |
	surgeAll.fd: Contains source code and makefile for surgeAll executable
--------------------
                    |
                    |
	tideAll.fd: Contains source code and makefile for tideAll executable
--------------------

Description:
	All the source code and make-age needed to compile the executables.

	Makefile: The master Makefile that kicks off the sorc makefiles and
	          lib makefiles. Just go to sorc/, type 'make' and read the
	          instructions

**********************************************
DEV DIRECTORY
**********************************************
Description: 
	runPost_ETSS.sh: Wrapper script used to test the code during development.
                  One can set several options in this script, the most
	          important of which is KEEPDATA, which either keeps the
	          output around or deletes it

**********************************************
DEV/TMP/COM/ETSS/PROD/YYYYMMDD DIRECTORY
**********************************************
Description:
	All output .csv and SHEF files, as well as surge, obs, and tide grids
	and input data go here after every dev run. Very important for
	debugging!

**********************************************
DEV/TMP/TMPNWPRD1 DIRECTORY
**********************************************
Sub-directories:
	etss_${job}.${pid} (job = parseDat, gridDat, combDat)

Description:
	Files only needed during run time and that also change every run are
	placed here temporarily and then removed after the code runs. So raw
	data files, lists of filenames, poescripts, and integer-ized grids go
	here. This is a temporary test directory for development purposes.

	fns_obs.txt, fns_ss.txt: List of date-based file names.
	obsGrid, surgeGrid, tideGrid: Integerized-grids.
	poescripts: Lists of commands for LSF to run in parallel.
	*.ss, *.shef: Raw BUFR data, named by date
