!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!c    PURPOSE:
!c 
!c       EXTRACT SURFACE P,U, AND V FROM AVN GRIB FILES THEN MAKE 35 DEGREE 
!c       WINDOWED DATA SET. THE TEMPORARY OUTPUT FILES ARE FORTRAN ARRAYS 
!c       (INSTEAD OF GRIB SUBSET 'GRBXX') AND ARE NOT SAVED.  
!c
!c    ARGUMENTS:
!c    
!c
!c    INPUT FILES:
!c       FORT.11~45  - 0 ~102 GFS U,V and P GRIB2 FILES
!c       FORT.49     - BASINS INFORMATION
!c
!c    OUTPUTFILES:
!c       FORT.51~56  - CUTTED U,V,P COVERING BASINS
!c
!c    LOG FILES:
!c       FORT.96 -  SDS LOG FILE FOR ANY ERROR IN GRIB_PUV AND GRIB_EX RUN.
!c
!c    VARIABLES:
!c
!c      INPUT
!c
!c     OUTPUT
!c
!c    AUTHORS:
!c       KIM/CHEN
!c           
!c    HISTORY:
!c       10/1994--KIM/CHEN Created the routine
!c       11/1995--C.MO     COMBINE OLD GRIB_PUV.F AND GRIB_EX.F
!C                         BY THE USE OF W3LIB SUBROUTINE GETGB.
!C       07/1998--J.CHEN   MODIFY FOR YEAR 2000 COMPLIANCE. 10-M WIND. 
!C       09/1998--SHIREY   CALLS TO W3TAG ORIGINALLY COMMENTED OUT...
!C                         MADE THE LINES EXECUTABLE IN THE CODE.
!C       03/2000--CHEN     CONVERTED TO RUN ON THE IBM SP.  CHANGES WERE
!C                         MADE IN OPENING GRIB FILES. CHANGED FROM .9995
!C                         SIGMA WINDS TO 10 M WINDS
!C       04/2014--Huiqing Liu /MDL CONVERTED TO USE GRIB2 FORMAT GFS FILES (.5 by .5 deg)
!c       01/2016--Huiqing Liu /MDL Enable to Process 102 hrs wind fields
!c       02/2017--Huiqing Liu /MDL Added header block
!c       08/2017--Huiqing Liu /MDL CONVERTED TO USE GFS_T1534 (13km) 
!c       05/2018--Huiqing Liu /MDL Optimize the codes to reduce I/O 
!c 
!c    NOTES: 
!c 
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      use grib_mod

      implicit none

      type (gribfield) :: Gfld
      logical          :: Unpack=.true.
      integer          :: K,Jksp,Jpdtn,Iounit,Latin1,Latin2,Lonin1
      integer          :: Lunit,Kf,Iunit,Iret,Jdisc,Jgdtn,Jskp
      integer          :: Iprj,Iyear,Imonth,Iday,Numbasin,Ii,L,I,J
      integer          :: Lonin2,Ilonul1,Ilonul2,Ihour,Ipint
      integer          :: Idatapnt,Idd,Iwnd,Jwnd,Ixx,Jxx
      integer          :: Ix1,Ix2,Iy1,Iy2

      integer,dimension(200)              :: Jids,Jpdt,Jgdt
      real,dimension(:),allocatable       :: P,U,V,Latu,Lonu
      integer*2,dimension(:,:),allocatable:: Iint2p,Iint2u,Iint2v

      

      character (len=80)  :: Title,Title1
      character (len=255) :: Fil_51,Filei,fileb
      character (len=11)  :: Envvar
      character (len=1)   :: Achr,Aaa

      character (len=3),dimension (12) ::  Amon
      DATA AMON/'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP',
     1    'OCT','NOV','DEC'/

!c     W3TAGB needs (Name, Julian day (see next line), seconds, org)
!c         tclsh : puts [clock format [clock seconds] -format "%j"]
      call W3TAGB('MDL_CY_PUV10',2012,0341,0000,'OST25')

      Iwnd = 3072 !GFS wind Dimension
      Jwnd = 1536
      Idd = 4718592 ! Iwnd * Jwnd

      allocate (P(Idd))
      allocate (U(Idd))
      allocate (V(Idd))

      allocate (Latu(Jwnd))
      allocate (Lonu(Iwnd))


!C     OPEN UNIT NUMBERS
!C         Input P(ressure)/U/V files (full field)  extracted from
!C         GRIB2 and stored in one temp file (kind of NDFD like).
!C         Log file for any errors in run 
      call getenv('FORT96',Filei)
      open(96,file=Filei)
!C         Input basin dimmenension file      
      call getenv('FORT49',Filei)
      open(49,file=Filei)

!C    GFS grid lat and lon file
      call getenv('FORT9',Filei)
      open(9,file=Filei)


      call getenv('FORT10',Filei)
      open(10,file=Filei)

!C         Output P(ressure)/U/V files Sampled to SLOSH grid.
      call getenv('FORT51',Filei)
      open(51,file=Filei,form='unformatted')
      call getenv('FORT52',Filei)
      open(52,file=Filei,form='unformatted')
      call getenv('FORT53',Filei)
      open(53,file=Filei,form='unformatted')
      call getenv('FORT54',Filei)
      open(54,file=Filei,form='unformatted')
      call getenv('FORT55',Filei)
      open(55,file=Filei,form='unformatted')
      call getenv('FORT56',Filei)
      open(56,file=Filei,form='unformatted')
!C   Read GFS grid lat and lon
      do i = 1, Iwnd
         read(9,*) Lonu(i) ! Data is from W to E (0 ~360) inner loop
      enddo
      close(9)
      do i = 1, Jwnd
         read(10,*) Latu(i)
         Latu(i) = Latu(i) * -1 ! Data is from N to S (90 ~ -90) outer loop
      enddo
      close(10)
!c  EXTRACT SURFACE PUV FROM AVN GRIB FILES FOR EVERY 1 HOUR PROJECTION.

      Lunit = 1 + 10
      Envvar = 'FORT  '
      write(Envvar(5:6),FMT='(I2)') Lunit
      call getenv(Envvar,Fileb)
      call baopenr(Lunit,Fileb,Iret)
      write(*,*) Lunit,Fileb,Iret
      
      do Iunit = 1, 103

         Jdisc = -1
         Jids = -9999
         Jgdtn = -1
         Jgdt = -9999
         Jpdt = -9999

         Jskp = 0
         Jpdtn = 0

!c  COMPUTE THE PROJECTION WE SHOULD BE WORKING WITH      
         Iprj = (Iunit - 1) * 1

         Jpdt(9) = Iprj
!c  GET MSL PRESSURE AS REAL ARRAY P

!c     Search for PRESS at Surface by production template 4.0
!c     NOT at sea surface

         Jpdt(1) = 003
         Jpdt(2) = 000
         Jpdt(10) = 001

         call getgb2(Lunit,0,Jskp,Jdisc,Jids,Jpdtn,Jpdt,Jgdtn,Jgdt,
     &               unpack,K,Gfld,Iret)
         P = Gfld%fld
         Kf = Gfld%ndpts
         write(*,*) Kf,Iret
         write(*,*) Gfld%idsect(9),Iprj

         if (Iret.ne.0) then
            exit
         endif

!c  GET 10-METER WIND COMPONENT U
!c     Search for U at 10 m by production template 4.0

         Jpdt(1) = 002
         Jpdt(2) = 002
         Jpdt(10) = 103

         call getgb2(Lunit,0,Jskp,Jdisc,Jids,Jpdtn,Jpdt,Jgdtn,Jgdt,
     &               Unpack,K,Gfld,Iret)
         U = Gfld%fld
         Kf = Gfld%ndpts

         if (Iret.ne.0) then
            exit
         endif


!c  GET 10-METER WIND COMPONENT V
!c     Search for V at 10 m by production template 4.0

         Jpdt(1) = 002
         Jpdt(2) = 003
         Jpdt(10) = 103

         call getgb2(Lunit,0,Jskp,Jdisc,Jids,Jpdtn,Jpdt,Jgdtn,Jgdt,
     &               Unpack,K,Gfld,Iret)
         V = Gfld%fld
       
         Kf = Gfld%ndpts

         if (Iret.ne.0) then
            exit
         endif


!C  GENERATE HEADER FOR OUTPUT FILE
        rewind(49)
        read (49,*) Numbasin
        do Ii = 1, Numbasin
           Iounit = 50 + Ii
           read (49,*) Latin1,Latin2
           read (49,'(A1)') Achr
           read (49,*) Lonin1,Lonin2
           read (49,*)
           if(Achr == 'W') then
              Ilonul1 = 360 - Lonin1
              Ilonul2 = 360 - Lonin2
           else
              Ilonul1 = Lonin1
              Ilonul2 = Lonin2
           endif
!C Find the correct wind window from GFS orginal grid           
           do i = 1, Iwnd
              if (Lonu(i) >= Ilonul1) then
                 Ix1 = i - 1
                 exit
              endif
           enddo
           do i = Ix1, Iwnd
              if (Lonu(i) >= Ilonul2) then
                 Ix2 = i + 1
                 exit
              endif
           enddo
           do j = 1, Jwnd
              if (Latin1 >= Latu(j)) then
                 Iy1 = j - 1
                 exit
              endif
           enddo
           do j = Iy1, Jwnd
              if (Latin2 > = Latu(j)) then
                 Iy2 = j + 1
                 exit
              endif
           enddo

           Ixx = (Iy2 - Iy1) + 1
           Jxx = (Ix2 - Ix1) + 1
!C
           allocate (Iint2p(Ixx,Jxx))
           allocate (Iint2u(Ixx,Jxx))
           allocate (Iint2v(Ixx,Jxx))
           Iint2p = 0
           Iint2u = 0
           Iint2v = 0

!C  PROCESS FOR ONE PROJECTION
           write(*,*) ' BASIN =',Ii,Ixx,Jxx,Iprj
           Iyear = Gfld%idsect(6)
           Imonth = Gfld%idsect(7)
           Iday = Gfld%idsect(8)
           Ihour = Gfld%idsect(9)
           Ipint = Iprj
           Title(1:17) = ' GRIB 10-METER   '
           write (Title(18:),101) Iyear,Iday,Amon(Imonth),Ihour,
     $                            Ipint
           Title1(10:) = '   COORDINATE (1,1) OF EXTRACTED FILE'
           write (TITLE1(1:9),'(1X,I4,I4)') Latin1,Lonin1
           write (Iounit) Ixx,Jxx,Ix1,Ix2,Iy1,Iy2
           write (Iounit) Title,Title1

           do I = Iy1, Iy2
           do J = Ix1, Ix2
              Idatapnt = (i - 1) * Iwnd + j
              Iint2u(I-Iy1+1,J-Ix1+1) = 10 * U(Idatapnt)
              Iint2v(I-Iy1+1,J-Ix1+1) = 10 * V(Idatapnt)
              Iint2p(I-Iy1+1,J-Ix1+1) = int(0.1*P(Idatapnt))-10000
           end do
           end do

           write (Iounit) ((Iint2u(i,j), i = 1, Ixx), j = 1, Jxx)
           write (Iounit) ((Iint2v(i,j), i = 1, Ixx), j = 1, Jxx)
           write (Iounit) ((Iint2p(i,j), i = 1, Ixx), j = 1, Jxx)

           deallocate (Iint2p)
           deallocate (Iint2u)
           deallocate (Iint2v)

        end Do
      end Do
      close (Lunit)

      if (Iret == 0) then
        Aaa = 'Y'
        write (96,100) Aaa


        close(96)
        close(49)
        close(51)
        close(52)
        close(53)
        close(54)
        close(55)
        close(56)

      else
        Aaa = 'N'
        write (96,100) Aaa,Iret,'=RETURN CODE'
      endif

100   FORMAT(A1,I5,A15)
101   FORMAT (I4,' ',I2,' ',A3,'.',1X,I2.2,'Z FT=  ',I2.2,' AVN')
!
      call gf_free(Gfld)
      deallocate (P)
      deallocate (U)
      deallocate (V)
      deallocate (Latu)
      deallocate (Lonu)

!
      call W3TAGE('MDL_CY_PUV10')

      stop
      end
