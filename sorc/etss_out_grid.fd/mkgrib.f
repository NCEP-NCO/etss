      subroutine mkgrib(Lcgrib,Ryear,Rmonth,Rday,Rhour,Rmin,Rsec,
     1                  Area,Ifcsthr)
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!c
!c    PURPOSE:
!c       SETTING THE GRIB2 DIFFERENT SECTION TABLES PARAMETER
!c      
!c
!c    ARGUMENTS:
!c
!c    INPUT FILES:
!c       None 
!c
!c    OUTPUTFILES:
!c       None
!c
!c    VARIABLES:
!c      INPUT
!c       AREA  == con (CONUS) OR ala (ALASKA)
!c      RYEAR  == YEAR OF THE MODEL RUN
!c     RMONTH  == MONTH OF THE MODEL RUN
!c       RDAY  == DAY OF THE MODEL RUN
!c      RHOUR  == HOUR OF THE MODEL RUN
!c       RMIN  == MIN OF THE MODEL RUN
!c       RSEC  == SECOND OF THE MODEL RUN
!c    IFCSTHR  == FORECAST HOUR
!c      OUTPUT
!c     LCGRIB  == GRIB2 DEFINITION VARIABLE
!c    AUTHORS:
!c       Modelers /MDL, Arthur, Taylor, Huiqing Liu /MDL
!c           
!c    HISTORY:
!c       03/1995--Modelers /MDL Created the routine
!c       10/2014--Huiqing Liu /MDL Updated the routine to read 2.5/3km mask files
!c       02/2015--Huiqing Liu /MDL Updated to use dynamicall allocated
!c                                 array instead of statically allocated arrays
!c       08/2015--Huiqing Liu /MDL Updated to use tropical and extra-tropical grids
!c       01/2016--Huiqing Liu /MDL Updated the routine to read different res
!c                                 mask files
!c       01/2017--Huiqing Liu /MDL Put the routine to a independent fortran file
!c       02/2017--Huiqing Liu /MDL Added header block
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      USE Mask_Array

      integer           :: Lcgrib,Ryear,Rmonth,Rday,Rhour,Rmin,Rsec
      integer           :: Ifcsthr
      character (len=3) :: Area

      integer           :: Ierr,Lcsec2,Idefnum,Numcoord,Ipdsnum,Idrsnum
      integer           :: Ngrdpts,Ibmap,Dsf,Itemp

      integer,dimension(2)  :: Lsec0
      integer,dimension(13) :: Lsec1
      integer,dimension(5)  :: Igds
      integer,dimension(1)  :: Ideflist

      real, dimension(1)    :: Coordlist

      integer,dimension(:), allocatable :: Igdstmpl,Ipdstmpl,Idrstmpl
      real, dimension(:), allocatable   :: Fld
  
      character (len=1), dimension (1)  :: Csec2

      Logical*1       Bmap(1)

      allocate (Igdstmpl(Ngdstmpl))
      allocate (Ipdstmpl(Ipdstmplen))
      allocate (Idrstmpl(Idrstmplen))
      allocate (Fld(Nxnymax))

C 10 = OCEANOGRAPHIC PRODUCT, 2 = EDITION NUMBER (GRIB2)
      LSEC0(1) = 10
      LSEC0(2) = 2
C 7 = NCEP, 14 = MDL, 4 VERSION, 1 = VERSION OF THE LOCAL TABLES.
      LSEC1(1) = 7
      LSEC1(2) = 14
      LSEC1(3) = 3
      LSEC1(4) = 1
C 1 = START OF FORECAST, RYEAR, RMONTH, RDAY, RHOUR, RMIN, RSEC
      LSEC1(5) = 1
      LSEC1(6) = RYEAR
      LSEC1(7) = RMONTH
      LSEC1(8) = RDAY
      LSEC1(9) = RHOUR
      LSEC1(10) = RMIN
      LSEC1(11) = RSEC
C 1 = OPERATIONAL TEST PRODUCT (0 WOULD BE OPERATIONAL)
      LSEC1(12) = 1
C 1 = FORECAST PRODUCTS
      LSEC1(13) = 1
      CALL GRIBCREATE(CGRIB,NGRIBM,LSEC0,LSEC1,IERR)
C CHECK THE RESULTS OF IERR.

      LCSEC2 = 0
      CALL ADDLOCAL(CGRIB,NGRIBM,CSEC2,LCSEC2,IERR)
C CHECK THE RESULTS OF IERR.

C 0 = USING TEMPLATES, GRID SPECIFIED IN 3.1
      IGDS(1) = 0
      IGDS(2) = NX * NY ! Grid numbers
C 0 = MEANS NO IDEFLIST, 0 MEANS NO APPENDED LIST
      IGDS(3) = 0
      IGDS(4) = 0
C 30 = LAMBERT, 20 = POLAR STEREOGRAPHIC
      IF(AREA=='con') THEN
        IGDS(5) = 30 ! Projection Type
      ELSE IF(AREA=='ala') THEN
        IGDS(5) = 20
      END IF
      IGDSTMPL(1) = 1
      IGDSTMPL(2) = 0
      IGDSTMPL(3) = 6371200 ! Radius of Earth
      IGDSTMPL(4) = 0
      IGDSTMPL(5) = 0
      IGDSTMPL(6) = 0
      IGDSTMPL(7) = 0
      IGDSTMPL(8) = NX ! number of points on parallel
      IGDSTMPL(9) = NY ! number of points on meridian
      IF(AREA=='con') THEN
        IGDSTMPL(10) = 20191999 !Lat1 20.191999
        IGDSTMPL(11) = 238445999 ! Lon1 238.445999
      ELSE IF(AREA=='ala') THEN
        IGDSTMPL(10) = 40530101
        IGDSTMPL(11) = 181429000
      END IF
C RESOLUTION FLAG IS 0.
      IGDSTMPL(12) = 0
      IF(AREA=='con') THEN
        IGDSTMPL(13) = 25000000
        IGDSTMPL(14) = 265000000
        IGDSTMPL(15) = Res_con !2.5km
        IGDSTMPL(16) = Res_con !2.5km
        IGDSTMPL(17) = 0
        IGDSTMPL(18) = 64
        IGDSTMPL(19) = 25000000
        IGDSTMPL(20) = 25000000
        IGDSTMPL(21) = -90000000
        IGDSTMPL(22) = 0
      ELSE IF(AREA=='ala') THEN
        IGDSTMPL(13) = 60000000
        IGDSTMPL(14) = 210000000
        IGDSTMPL(15) = Res_ala !3.0km
        IGDSTMPL(16) = Res_ala !3.0km
        IGDSTMPL(17) = 0
        IGDSTMPL(18) = 64
      END IF
      IDEFNUM = 0
      CALL ADDGRID(CGRIB,NGRIBM,IGDS,IGDSTMPL,NGDSTMPL,IDEFLIST,
     1             IDEFNUM,IERR)
C CHECK THE RESULTS OF IERR.

C 0 = FORECAST AT A HORIZONTAL LEVEL AT A POINT IN TIME
      IPDSNUM = 0
      IPDSTMPL(1) = 3
! PRODUCT NAME 193--ETSRG 250--ETCWL
      IF(FLEEXT=='stormtide') THEN
         IPDSTMPL(2) = 250
      ELSEIF(FLEEXT=='stormsurge') THEN
         IPDSTMPL(2) = 193
      ELSE
         IPDSTMPL(2) = 251  ! Tide only
      ENDIF
c 2 = FORECAST
      IPDSTMPL(3) = 2
      IPDSTMPL(4) = 0

!      IF(AREA=='con') THEN
!        IPDSTMPL(5) = 14
!      ELSE
!        IPDSTMPL(5) = 17
!      ENDIF
! ETSS processing ID 16
      IPDSTMPL(5) = 16
!
      IPDSTMPL(6) = 65535
      IPDSTMPL(7) = 255
      IPDSTMPL(8) = 1
      IPDSTMPL(9) = IFCSTHR
c 1 = GROUND OR WATER SURFACE
      IPDSTMPL(10) = 1
      IPDSTMPL(11) = 0
      IPDSTMPL(12) = 0
C -1 is all 1's if we are dealing with signed integers.
C 13, and 14 only need 1 byte of all 1's (missing), so could use 255
      IPDSTMPL(13) = -1
      IPDSTMPL(14) = -1
      IPDSTMPL(15) = -1
      NUMCOORD = 0
      NGRDPTS = NX * NY
      IDRSNUM = 2
C REFERENCE VALUE IS SET TO 9999 FOR
      IDRSTMPL(1) = 9999
      IDRSTMPL(2) = 0
C 5 = DECIMAL SCALE FACTOR
!      DSF = 5
      DSF = 3
      IDRSTMPL(3) = DSF
      IDRSTMPL(4) = 9999
C 0 = FLOATING POINT (ORIGINAL DATA WAS A FLOATING POINT NUMBER)
      IDRSTMPL(5) = 0
      IDRSTMPL(6) = 9999
C 1 = MISSING VALUE MANAGEMENT (PRIMARY ONLY)
      IDRSTMPL(7) = 1
      call mkieee(9999.,IDRSTMPL(8),1)
      call mkieee(9999.,IDRSTMPL(9),1)
      IDRSTMPL(10) = 9999
      IDRSTMPL(11) = 9999
      IDRSTMPL(12) = 9999
      IDRSTMPL(13) = 9999
      IDRSTMPL(14) = 9999
      IDRSTMPL(15) = 9999
      IDRSTMPL(16) = 9999

C LOOP THROUGH THE DATA.
C Y (ft) * (12inch/ft) * (2.54cm/inch) * (m/100cm) = X (m)
C Y (ft) * M_FT = X (m)
C M_FT = 0.3048
      DO 150 J=1,NY
        DO 140 I=1,NX
          IF (HA(I,J).NE.9999.and.HA(I,J).NE.36.and.HA(I,J).NE.67.and.
     1        HA(I,J).NE.99) THEN
            ITEMP = HA(I,J) * 0.3048 * 10**DSF + 0.5
            FLD(I + (J - 1) * NX) = ITEMP / (10**DSF + 0.0)
          ELSE
            FLD(I + (J - 1) * NX) = 9999
          ENDIF
 140    CONTINUE
 150  CONTINUE
C NO BIT MAP APPLIES FOR THE DATA.
      IBMAP = 255
!      write(*,*)maxval(FLD)
      CALL ADDFIELD(CGRIB,NGRIBM,IPDSNUM,IPDSTMPL,IPDSTMPLEN,
     1              COORDLIST,NUMCOORD,IDRSNUM,IDRSTMPL,
     1              IDRSTMPLEN,FLD,NGRDPTS,IBMAP,BMAP,IERR)
C CHECK THE RESULTS OF IERR.

C RENAME LCGRIB TO LENGRIB
C RENAME NGRIBM TO LCGRIB
      CALL GRIBEND(CGRIB,NGRIBM,LCGRIB,IERR)
C CHECK THE RESULTS OF IERR.
      RETURN
      END

