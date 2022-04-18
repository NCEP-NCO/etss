c-----------------------------------------------------------------------
c combineAll.f
c-----------------------------------------------------------------------
c Author: Ryan Schuster (ryan.schuster@noaa.gov)
c History: Program created in 2014
c Updated by Huiqing Liu in March 2016
c-----------------------------------------------------------------------
c Abstract:
c Reads the integer tide, obs, and surge grids, uses them to
c calculate total water level and anomaly, then formats that
c data for use in two types of output files (.csv and .shef)
c 1) Sets up relevant filenames from envir variables; gets relevant
c    info from master file; gets list of dates from datelist;
c    initializes arrays
c 2) Sets up WMO headers and AWIPS IDs for the six output SHEF files
c 3) Loops through all COOPS stations and uses output in obs, tide, and
c    surge grids to create specially-formatted csv files containing obs,
c    tides, and surge for those stations; accounts for missing data.
c 4) Calculates total water level and anomaly
c 5) Calls makeSHEF.f to write out SHEF-encoded total water level or
c    surge data
c
c Parameters:
c  Inputs:  none
c  Outputs: ${COMOUT}/xxxxxxx.csv - specially-formatted .csv files
c                                   containing tide,
c                                   obs, and surge data where the
c                                   'xxxxxxx' is the
c                                   station's COOPS ID number
c           ${COMOUT}/mdlsurge.HH.TWx.shef - output shef files where HH
c                                            is the latest forecast
c                                            cycle and x is the
c                                            relevant geographical basin
c-----------------------------------------------------------------------

       PROGRAM COMBINEALL

C      Get list of dates
!-----------------------------------------------------------------------
!Huiqing.Liu/MDL March 2016
! 5 days + 96 hrs = 12960 mins and divide by 6 mins step + 1 equals 2161
! lines in datelist files
!       CHARACTER(12) DATES(2161),TS,DATE 
!5 days + 102 hrs = 13320 mins and divide by 6 mins step + 1 equals 2221
! lines in datelist files
!-----------------------------------------------------------------------
       INTEGER :: NDATES
       CHARACTER(12) ,  ALLOCATABLE :: DATES(:)
       CHARACTER(12) TS,DATE
!
       INTEGER :: TLAST,TOTALNUM
!       CHARACTER(12) DATES(2221),TS,DATE

C      Get number of stations
       INTEGER NLINES

C      Indices and throwaways
       INTEGER II,JJ,CTR
       CHARACTER(120) NOPE

C      Grid line by line
       INTEGER, ALLOCATABLE :: SSARR(:),TIARR(:),OBARR(:)
!
!-----------------------------------------------------------------------
! Added by Huiqing.Liu /MDL April 2014 Reduce I/O times
! Read the Surge, Tide and Obs grid data and restore to a 2-D arrays
! to avoid reading files multiple times by using 1-D arrays
!-----------------------------------------------------------------------

       INTEGER, ALLOCATABLE :: SSGRID(:,:),TIGRID(:,:),OBGRID(:,:)
!-----------------------------------------------------------------------
!
!
       REAL SS,TI,OB,AN,TW

C      Station id and associated filename
       CHARACTER(7), ALLOCATABLE :: STIDS(:)
       CHARACTER(7) STID
       CHARACTER(5), ALLOCATABLE :: NWSLIS(:)
       CHARACTER(5) NWSLI
       CHARACTER(1), ALLOCATABLE :: OBSBS(:), TIDBS(:)
       CHARACTER(1) OBSB,TIDB

C      Average anomaly 
       REAL ANSUM, ANAVG, LSTAN, ANLIN, ANDIFF
       INTEGER FLAG

C      Shef output file stuff
       CHARACTER(2) AREA(5)/'US','US','US','AK','AK'/
       CHARACTER(3) AWIPS(5)/'TWE','TWG','TWP','TWC','TWB'/
       CHARACTER(6) WMODATE
       CHARACTER(25) HEADER
       CHARACTER(49) HEADER1
       CHARACTER(46) HEADER2
       CHARACTER(34) HEADER3
       CHARACTER(1) BSN
       CHARACTER(3), ALLOCATABLE :: BSNS(:)
       INTEGER UNITS(5)

C      Shef encoding arrays
!-----------------------------------------------------------------------
!      1 + 96 forecast hours
!       REAL SSSHEF(97),TISHEF(97),ANSHEF(97)
!      1 + 102 forecast hours
!-----------------------------------------------------------------------
       REAL SSSHEF(103),TISHEF(103),ANSHEF(103)
!
C      File names
       CHARACTER(255) MASTER,DATELIST,SURGEGRID,OBSGRID,TIDEGRID,STN
!-----------------------------------------------------------------------
! Added by H.Liu /MDL June 2020
! MLLW conversion file parm/model/mllw.csv
! If flagmllw = 0, apply conversion by obs + convmllw (ft)
! Else flagmllw = 1 (already in mllw), do nothing
!-----------------------------------------------------------------------
       CHARACTER(255) MLLW
       integer, allocatable :: flagmllw(:)
       real, allocatable :: convmllw(:)
!-----------------------------------------------------------------------
       CHARACTER(255) SHEFS(5)

C ---------------------------------------------------------------------
C  Get environment variable filenames
       CALL GET_ENVIRONMENT_VARIABLE('FORT10',MLLW)
       CALL GET_ENVIRONMENT_VARIABLE('FORT11',MASTER)
       CALL GET_ENVIRONMENT_VARIABLE('FORT12',DATELIST)
       CALL GET_ENVIRONMENT_VARIABLE('FORT13',SURGEGRID)
       CALL GET_ENVIRONMENT_VARIABLE('FORT14',TIDEGRID)
       CALL GET_ENVIRONMENT_VARIABLE('FORT15',OBSGRID)
       CALL GET_ENVIRONMENT_VARIABLE('FORT51',SHEFS(1))
       CALL GET_ENVIRONMENT_VARIABLE('FORT52',SHEFS(2))
       CALL GET_ENVIRONMENT_VARIABLE('FORT53',SHEFS(3))
       CALL GET_ENVIRONMENT_VARIABLE('FORT54',SHEFS(4))
       CALL GET_ENVIRONMENT_VARIABLE('FORT55',SHEFS(5))
       CALL GET_ENVIRONMENT_VARIABLE('FORT57',STN)
     
C  Get number of stations
       CALL NUMLINES(TRIM(MASTER),NLINES)
       CALL NUMLINES(TRIM(DATELIST),NDATES)

C  Allocate grid arrays
       ALLOCATE(DATES(NDATES))

       ALLOCATE(SSARR(NLINES))
       ALLOCATE(TIARR(NLINES))
       ALLOCATE(OBARR(NLINES))
       ALLOCATE(STIDS(NLINES))
       ALLOCATE(NWSLIS(NLINES))
       ALLOCATE(OBSBS(NLINES))
       ALLOCATE(TIDBS(NLINES))
       ALLOCATE(BSNS(NLINES))

       ALLOCATE(flagmllw(NLINES))
       ALLOCATE(convmllw(NLINES))

!
!-----------------------------------------------------------------------
! Added by Huiqing.Liu /MDL April 2014 Reduce I/O times
!-----------------------------------------------------------------------

!      ALLOCATE(SSGRID(2221,NLINES))
!      ALLOCATE(TIGRID(2221,NLINES))
!      ALLOCATE(OBGRID(2221,NLINES))
      ALLOCATE(SSGRID(NDATES,NLINES))
      ALLOCATE(TIGRID(NDATES,NLINES))
      ALLOCATE(OBGRID(NDATES,NLINES))

C Initialize SHEF arrays
!       DO II = 1,97
       DO II = 1,103
         TISHEF(II) = 9999.0
         SSSHEF(II) = 9999.0
         ANSHEF(II) = 9999.0
       END DO

C  Get dates
       OPEN(12,FILE=TRIM(DATELIST),ACTION='READ')
       DO II = 1,NDATES
         READ(12,'(A12)'), DATES(II)
       ENDDO
       CLOSE(12)
! Get the current date and cycle 5 days (24*5*60/6)
       DATE = DATES(1201)

C  Open the MLLW conversion files
       OPEN(10,FILE=TRIM(MLLW))
       READ(10,*) NOPE,NOPE,NOPE,NOPE,NOPE,NOPE,NOPE
C  Open the master file       
       OPEN(11,FILE=TRIM(MASTER))

C  Loop through stations
       II = 0
       DO
         II = II + 1
C        Read this station ID from master file
         READ(11,*,END=20), NOPE,STID,NWSLI,NOPE,NOPE,NOPE,NOPE,
     &                      NOPE,NOPE,OBSB,TIDB,NOPE,NOPE,NOPE,NOPE,
     &                      BSN
         READ(10,*)NOPE,NOPE,NOPE,NOPE,NOPE,
     &                      flagmllw(II),convmllw(II)
         STIDS(II) = STID
         NWSLIS(II) = NWSLI
         OBSBS(II) = OBSB
         TIDBS(II) = TIDB
         BSNS(II) = "TW" // BSN
       END DO
 20    CLOSE(11)
       CLOSE(10)

C     Open up all the basin-specific SHEF output files and give them the
C     correct WMO header
      WMODATE = DATE(7:8) // DATE(9:12)
      DO II = 1,5
C CALL GET_ENVIRONMENT_VARIABLE('FORT2'//[STRING OF II],SHEFOUT)
C Do stuff with SHEFOUT, make sure to set the units correctly
! Write SHEF file header Huiqing.Liu/MDL Nov.,2016
        HEADER = "SR" // AREA(II) // "70 KWNO " // "TID" // AWIPS(II)
     &           // " " // WMODATE
        OPEN(II+50,FILE=TRIM(SHEFS(II)))
        UNITS(II) = II+50 ! File units
        WRITE(UNITS(II),'(A25)') HEADER ! Orginal Header
! Adding three more lines header information Huiqing.Liu/MDL Nov. 2016
        HEADER1 = ":SHEF ENCODED 1 HOUR STORM SURGE + TIDE GUIDANCE"
        HEADER2 = ":WATER LEVEL VALUES REFERENCED TO MLLW IN FEET"
        HEADER3 = ":PROVIDED BY DOC/NOAA/NWS/OSTI/MDL"

        WRITE(UNITS(II),'(A49)') HEADER1
        WRITE(UNITS(II),'(A46)') HEADER2
        WRITE(UNITS(II),'(A34)') HEADER3

      END DO

       DO II = 1,NLINES
!         IF (TIDBS(II).NE.'0') THEN
C          Open file for this station
           STN((LEN(TRIM(STN))-10):(LEN(TRIM(STN))-4)) = STIDS(II)
           OPEN(57,FILE=TRIM(STN),ACTION='WRITE')
!         END IF

C        Initialize anom avg
         ANSUM = 9999
         FLAG = 0
         TLAST = 1200
C        Open grids to get data
!-----------------------------------------------------------------------
! Added by Huiqing.Liu /MDL April 2014 Reduce I/O times
!        Only read grid data for the first time and store to a 2-D arrays
!-----------------------------------------------------------------------
!
         IF (II == 1) THEN
            OPEN(13,FILE=TRIM(SURGEGRID),ACTION='READ')
            OPEN(14,FILE=TRIM(TIDEGRID),ACTION='READ')
            OPEN(15,FILE=TRIM(OBSGRID),ACTION='READ')
         ENDIF
!-----------------------------------------------------------------------
!

         CTR = 0
         DO JJ = 1,NDATES
           TS = DATES(JJ)

C          Grab a new row (time stamp) from the grids
!
           IF (II == 1) THEN
              READ(13,*), SSGRID(JJ,:)
              READ(14,*), TIGRID(JJ,:)
              READ(15,*), OBGRID(JJ,:)
           ENDIF

!-----------------------------------------------------------------------
!           READ(13,*), SSARR(:)
!           READ(14,*), TIARR(:)
!           READ(15,*), OBARR(:)
            SSARR(:) = SSGRID(JJ,:)
            TIARR(:) = TIGRID(JJ,:)
            OBARR(:) = OBGRID(JJ,:)
!
!-----------------------------------------------------------------------
           IF (SSARR(II).EQ.9999 .OR. SSARR(II).EQ.0) THEN
             SS = SSARR(II)
           ELSE
             SS = FLOAT(SSARR(II))/1000
           END IF

           IF (TIARR(II).EQ.9999 .OR. TIARR(II).EQ.0) THEN
             TI = TIARR(II)
           ELSE
             TI = FLOAT(TIARR(II))/1000
           END IF


! Huiqing.Liu 02/2020
! Remove  "OBARR(II).EQ.0"
!           IF (OBARR(II).EQ.9999 .OR. OBARR(II).EQ.0) THEN
           IF (OBARR(II).EQ.9999) THEN
!--------------------------------------------------------------------------
!Huiqing.Liu/Ace Info 04/2018
!Bufr xx012 obs is at 6 mins interval, 00,06,12,18,24,30,36,42,48,54, however
!Bufr xx005 obs only at 24 mins and 54 mins (30 mins interval),or only at 24 mins
!Therefore, we need treat obs at 54 mins as the obs at 00 results or at 24 mins as 00 results
!Also move Tide Signal to 24 mins to avoid tidal phase shift
!--------------------------------------------------------------------------
             IF (JJ.GT.1.and.OBGRID(JJ-1,II).NE.9999.AND.
     $          MOD(JJ-1,10).EQ.0) THEN
                OB = FLOAT(OBGRID(JJ-1,II))/1000 
             ELSE IF (JJ.GT.6.and.OBGRID(JJ-6,II).NE.9999.AND.
     $          MOD(JJ-1,10).EQ.0) THEN
                OB = FLOAT(OBGRID(JJ-6,II))/1000
                TI = FLOAT(TIGRID(JJ-6,II))/1000                
             ELSE
                OB = 9999
             END IF
!--------------------------------------------------------------------------
           ELSE
! Huiqing.Liu 02/2020
! Add Obs fileter to remove abnomal obs (Spike > 20 ft)
!
             IF (JJ>1.and.abs((OBARR(II)-OBGRID(JJ-1,II))/1000.)
     $          <20) then
! Huiqing.Liu 02/2020
! Adjust obs datum for some of stations
!
!                IF (STIDS(II).EQ.'est0002') THEN
!                   OB = FLOAT(OBARR(II))/1000 - 6.62
!                   OB = FLOAT(OBARR(II))/1000 
!                ELSEIF (STIDS(II).EQ.'est0031') THEN
!                  OB = FLOAT(OBARR(II))/1000 - 2.96
!                ELSEIF (STIDS(II).EQ.'8462752') THEN
!                   OB = FLOAT(OBARR(II))/1000 + 1.84
!                ELSEIF (STIDS(II).EQ.'8638051') THEN
!                   OB = FLOAT(OBARR(II))/1000 + 1.25
!                ELSEIF (STIDS(II).EQ.'8638288') THEN
!                   OB = FLOAT(OBARR(II))/1000 + 1.13
!                ELSEIF (STIDS(II).EQ.'8638409') THEN
!                   OB = FLOAT(OBARR(II))/1000 + 2.03 ! + 1.95
!                elseif (STIDS(II).eq.'9468756')then
!                   if (abs(OBGRID(JJ,II)/1000.)<10) then
!                      OB = FLOAT(OBGRID(JJ,II))/1000
!                   else
!                      OB = 9999
!                   endif
                OB = FLOAT(OBGRID(JJ,II))/1000
             ELSE
                if (jj == 1)  then
                   OB = FLOAT(OBGRID(JJ,II))/1000
                else
                   OB = 9999
                endif
             ENDIF

!--------------------------------------------------------------------------
           END IF
!-----------------------------------------------------------------------
! Added H.Liu /MDL June 2020
! If flagmllw = 0, apply conversion by obs + convmllw (ft)
! Else flagmllw = 1 (already in mllw), do nothing
!-----------------------------------------------------------------------
           if (flagmllw(II).eq.0 .and.OB.ne.9999) then
              ob = ob + convmllw(II)
           endif
!-----------------------------------------------------------------------


!           if (STIDS(II).eq.'9468756')then
!                if (OB > 10) then
!                   OB = 9999
!                endif
!           endif
C          If we have obs, tide, and surge at this data point
C          then calculate the anomaly and total water level at
C          this point
           IF ((OB.NE.9999.0).AND.(TI.NE.9999.0)
     &         .AND.(SS.NE.9999.0)) THEN
! not forecast part
             
             AN = OB - (TI + SS)
             IF (ANSUM.NE.9999) THEN
               ANSUM = ANSUM + AN
             ELSE
               ANSUM = AN
             END IF
             TW = TI + SS + AN
 
             LSTAN = AN

C          If we only have tide and surge at this point...
           ELSE IF ((OB.EQ.9999.0).AND.(TI.NE.9999.0)
     &         .AND.(SS.NE.9999.0)) THEN
C            If we're in the forecast portion of the data output...
             IF ((ANSUM.NE.9999).AND.(JJ.GT.1201)) THEN
               if (FLAG.EQ.0) THEN
C              Get the last anomaly value before we switch
C              to the average
                 ANLIN = LSTAN
! Remeber the last time having obs
                 TLAST=JJ
                 TOTALNUM=JJ/10
!
                 
                 FLAG = 1

C              Get average and diff between it and last
C              anom value
!                  ANAVG = ANSUM / 120
                  ANAVG = ANSUM / TOTALNUM
                  ANDIFF = ANAVG - LSTAN
                endif
!               IF (JJ.LE.1321) THEN
!               IF (JJ.LE.TLAST+121) THEN
               IF (JJ.LE.TLAST+111) THEN
C              If we're in the first 12 hours of the forecast
C              Interpolate linearly toward the average
                 ANLIN = ANLIN + (ANDIFF / 12)
                 AN = ANLIN
                 TW = TI + SS + AN
               ELSE
C              Then just put the average
                 AN = ANAVG
                 TW = TI + SS + AN
               ENDIF
!
!
             ELSE
C            We're not in the forecast portion, so no anomaly; use
C            tide and surge to get the uncorrected total water level
               TW = TI + SS
               AN = 9999
             END IF
           ELSE
C          Surge only: Not enough data to get anomaly or total water
C          level
             AN = 9999
!             TW = 9999
             TW = SS
           END IF
!-----------------------------------
! Adding header to *.csv file H.Liu
!----------------------------------
           IF (JJ.EQ.1) THEN
             WRITE(57,'(A13,6A9)'),'TIME,','TIDE,','OB,','SURGE,',
     &                             'BIAS,','TWL'
           ENDIF
!----------------------------------
!           IF (TIDBS(II).NE.'0') THEN
C            Write row to output file
           if (STIDS(II).eq.'9468333'.or.STIDS(II).eq.'8740166') then
              if (mod(JJ-1,10).ne.0) OB = 9999
              TI = FLOAT(TIARR(II))/1000
           endif
             WRITE(57,'(A12,A1,F8.3,A1,F8.3,A1,F8.3,A1,F8.3,A1,F8.3)'),
     &                           TS,',',TI,',',OB,',',SS,',',AN,',',TW
!           END IF

C          Get values for SHEF encoding if we're on the hour
C          (shef values are hourly)
!         Only 102 forecast results not includes nowCast results
!         (1200th)
           IF (JJ.GT.1200) THEN
             IF (MOD(CTR,10).EQ.0) THEN
               SSSHEF(CTR/10 + 1) = SS 
               TISHEF(CTR/10 + 1) = TI
               ANSHEF(CTR/10 + 1) = AN
             END IF
             CTR = CTR + 1
           END IF

         END DO
!
!-----------------------------------------------------------------------
         IF (II == 1) THEN
            CLOSE(13)
            CLOSE(14)
            CLOSE(15)
         ENDIF
!
!         IF (TIDBS(II).NE.'0') THEN
           CLOSE(57)
!         END IF

C        Can't SHEF-encode if there's no NWSLI, so check that there is
C        one first
         IF ((NWSLIS(II).NE.'ZZZZZ').AND.(BSNS(II).NE.'TW0')) THEN
           DO MM = 1,5
             IF (BSNS(II).EQ.AWIPS(MM)) THEN
               CALL MAKESHEF(SSSHEF,TISHEF,ANSHEF,NWSLIS(II),
     &                       OBSBS(II),TIDBS(II),DATE,UNITS(MM));
             END IF
           END DO
         END IF
       END DO

C      Close SHEF output files
       DO II = 51,55
         CLOSE(II)
       END DO
C  Deallocate grid arrays
       DEALLOCATE(SSARR)
       DEALLOCATE(TIARR)
       DEALLOCATE(OBARR)
       DEALLOCATE(STIDS)
       DEALLOCATE(NWSLIS)
       DEALLOCATE(OBSBS)
       DEALLOCATE(TIDBS)
       DEALLOCATE(BSNS)
       DEALLOCATE(flagmllw)
       DEALLOCATE(convmllw)

!
       DEALLOCATE(DATES)
       DEALLOCATE(SSGRID)
       DEALLOCATE(TIGRID)
       DEALLOCATE(OBGRID)
!
       STOP
       END
