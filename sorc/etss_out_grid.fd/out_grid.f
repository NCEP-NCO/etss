!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!c    PURPOSE:
!c 
!c       MAIN PROGRAM TO POST PROCESSING OF THE ETSS GRIDDED DATA
!c
!c    ARGUMENTS:
!c    
!c       POST PROCESSING OF THE ETSS OUTPUT DATA READ DATA FROM SSGRID.xxx AND 
!c       MERGED INTO NDFD HOURLY GRIB2 FILES SKIP THE HALF HOUR RECORDS 
!c
!c       METHOD: DIVIDE THIS INTO THREE CATEGORIES
!c         (1) Extract surge values from tropical grids,extra-tropical grids
!c             and merged into CONUS grids in 2.5km (East Coast, 
!c             GULF of Mexico, NEP/West Coast)
!c         (2) Extract surge values from extropical grids  and merged into ALSKA 
!c             grids in 3km (BBC,GULF of AK/NEP grids)
!c         (3) Extract surge values from tropical grids,extra-tropical grids
!c             and merged into CONUS grids in 625m (East Coast and
!c             GULF of Mexico)
!c
!c    INPUT FILES:
!c       FORT.10  - AREA
!c
!c    OUTPUTFILES:
!c
!c
!c    VARIABLES:
!c
!c      INPUT
!c       prod     == stn/exc/pro
!c
!c     OUTPUT
!c
!c    AUTHORS:
!c       Huiqing Liu /MDL Jan. 2015 
!c           
!c    HISTORY:
!c       01/2015--Huiqing Liu /MDL Created routine
!c       02/2015--Huiqing Liu /MDL Put the Mask related array to a module
!c       01/2016--Huiqing Liu /MDL Extended to 102 hours
!c       02/2017--Huiqing Liu /MDL Added header block
!c
!c    NOTES:
!c       INCLUDEING MODULE SUBSORT,WHICH WILL BE USED BY OTHER THREE SUBROUTINES
!c
!c---------------------------------------------------
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      module Mask_Array

      integer  :: Nx,Ny,Nxnymax,Ngribm,Ngdstmpl,Ipdstmplen,Idrstmplen
      integer  :: Res_con,Res_ala,Nrec1

      integer,dimension(:,:,:),allocatable :: Ival,Jval
      integer,dimension(:,:),  allocatable :: Mask,Perc
      integer,dimension(:),    allocatable :: Pid

      real,dimension(:,:),     allocatable :: Ha

      character (len=1),dimension(:),allocatable :: Cgrib
      character (len=10)                         :: Fleext

      end module Mask_Array

      program out_grid

      use Mask_Array
      
      implicit none

      character (len=255)  :: Fil_11
      character (len=3)    :: Area
      character (len=1)    :: Tropical
      integer              :: startH,endH

!C     FORT.11  - CONTROL FILE FOR AREA AND PRODUCT TYPE,NESTING
      call getenv('FORT11',Fil_11)
      open(11,file=Fil_11)

      read(11,*) Area, Fleext, Tropical,startH,endH
      write (*,*) 'Area is: ', Area

      if (Tropical == 'Y') then
         call merge2p5km (AREA) ! Merging from extropical and tropical grids
      else if (Tropical == 'N') then
         call merge3km (AREA) ! Merging only from extropical grids
!      else if (Tropical == 'M') then
!         call merge625m_max (AREA)
      else
         call merge625m (AREA,startH,endH) ! Merging 625m NDFD grids
      end if

      end

