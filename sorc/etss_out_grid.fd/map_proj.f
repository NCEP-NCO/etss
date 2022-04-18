      subroutine map_proj(Mm,Numm)
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
!c
!c    PURPOSE:
!c       READ MERGING MASK FILE FOR CONUS AND ALASKA GRIDS
!c       PROJECTION THE CONUS/ALASKA NDFD GRID NUMBER TO MODEL BASIN GRID NUMBER
!c
!c    ARGUMENTS:
!c       READ DATA FROM SSGRID.CCB(00a for example)
!c       GENERATE MAXIMUM,MINNIMUM AND MEAN OF CONTROL AND ENSEMBLE RUNS
!c
!c    INPUT FILES:
!c       FORT.16  - MAP PROJECTION GRIDS alaska.bin (3km)
!c       FORT.49  - MAP PROJECTION GRIDS conus.bin (2.5km/625m)
!c
!c
!c    OUTPUTFILES:
!c
!c
!c    VARIABLES:
!c      INPUT
!c       MM    == BASIN NUMBERS
!c       numm  == NUMBER of MASK FILE (1 - 3km alaska; 2 - 2.5km conus and 
!c                                     3 - 625m conus)
!c     OUTPUT
!c       Mask  == mask variable (0 - no value; 1 - get value from basin grid)
!c       Ival  == I-index of merging basins grid
!c       Jval  == J-index of merging basins grid
!c
!c    AUTHORS:
!c       Modelers /MDL, Arthur, Taylor, Huiqing Liu /MDL
!c           
!c    HISTORY:
!c       03/1995--Modelers /MDL Created the routine
!c       10/2014--Huiqing Liu /MDL Updated the routine to read 2.5/3km mask 
!c                                 files
!c       01/2016--Huiqing Liu /MDL Updated the routine to read different res
!c                                 mask files
!c       01/2017--Huiqing Liu /MDL Put the routine to a independent fortran file
!c       02/2017--Huiqing Liu /MDL Added header block
!c
!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      use Mask_Array

      implicit none

      character (len=7)    :: Area
      character (len=5)    :: Basin

      integer              :: Nbasin,Mm,k,l,Numm,i,j,Ii,m
      integer,allocatable  :: I_lcal(:,:), J_lcal(:,:)
      integer,allocatable  :: Perc1(:),Mask1(:),Ival1(:,:),Jval1(:,:)
      integer,allocatable  :: I_lcal1(:), J_lcal1(:)


      if (Numm == 1) then
         read(16) Area
         write(*,*)'Reading Merging Mask File for ',Area
         read(16) Nx, Ny

         allocate (Mask(Nx,Ny))
         allocate (Ival(Mm,Nx,Ny))
         allocate (Jval(Mm,Nx,Ny))
         allocate (I_lcal(Nx,Ny))
         allocate (J_lcal(Nx,Ny))

         read(16) ((Mask(i,j), i = 1, Nx), j = 1, Ny)
         read(16) Nbasin
         if (Nbasin .ne. Mm) write(*,*) 'WRONG NUMBER OF BASINS !'
         do m = 1, Mm
            read(16) Basin
            read(16) ((I_lcal(i,j), i = 1, Nx), j = 1, Ny)
            read(16) ((J_lcal(i,j), i = 1, Nx), j = 1, Ny)
            Ival(m,:,:) = I_lcal
            Jval(m,:,:) = J_lcal
         end do
         write(*,*)'Finished Reading Merging Mask file from Extra-Trop'
         deallocate (I_lcal)
         deallocate (J_lcal)

      else if (Numm == 2) then
         read(49) Area
         write(*,*)'Reading Merging Mask File for ', Area
         read(49) Nx, Ny

         allocate (Mask(Nx,Ny))
         allocate (Perc(Nx,Ny))
         allocate (Ival(Mm,Nx,Ny))
         allocate (Jval(Mm,Nx,Ny))
         allocate (I_lcal(Nx,Ny))
         allocate (J_lcal(Nx,Ny))

         read(49) ((Mask(i,j), i = 1, Nx), j = 1, Ny)
         read(49) ((Perc(I,J), i = 1, Nx), j = 1, Ny)
         read(49) Nbasin
         if (Nbasin .ne. Mm) write(*,*) 'WRONG NUMBER OF BASINS !'
         do m = 1, Mm
            read(49) Basin
            read(49) ((I_lcal(i,j), i =1, Nx), j = 1, Ny)
            read(49) ((J_lcal(i,j), i =1, Nx), j = 1, Ny)
            Ival(m,:,:) = I_lcal
            Jval(m,:,:) = J_lcal
         end do
         write(*,*)'Finished Reading Merging Mask file'
         deallocate (I_lcal)
         deallocate (J_lcal)

      else
         read(49) Area
         WRITE(*,*)'Reading Merging Mask File for ', Area
         read(49) Nx, Ny
         read(49) Nrec1

         allocate (Pid(Nrec1))
         allocate (Perc1(Nrec1))
         allocate (Mask1(Nrec1))
         allocate (Ival1(Mm,Nrec1))
         allocate (Jval1(Mm,Nrec1))
         allocate (I_lcal1(Nrec1))
         allocate (J_lcal1(Nrec1))

         allocate (Mask(Nx,Ny))
         allocate (Perc(Nx,Ny))
         allocate (Ival(Mm,Nx,Ny))
         allocate (Jval(Mm,Nx,Ny))

         Pid = 0
         Perc1 = 0
         Mask1 = 0
         Ival1 = 0
         Jval1 = 0
         Mask = 0
         Perc = 0
         Ival = 0
         Jval = 0

         read(49) (Pid(i), i = 1, Nrec1)
         read(49) (Mask1(i), i = 1, Nrec1)
         read(49) (Perc1(i), i = 1, Nrec1)

         read(49) Nbasin
         if (Nbasin .ne. Mm) write(*,*) 'WRONG NUMBER OF BASINS !'
         do m = 1, Mm
            read(49) Basin
            read(49) (I_lcal1(i), i = 1, Nrec1)
            read(49) (J_lcal1(i), i = 1, Nrec1)
            Ival1(M,:) = I_lcal1
            Jval1(M,:) = J_lcal1
         end do
         do Ii = 1, Nrec1
            i = Pid(Ii) / 10000
            j = Pid(Ii) - i * 10000
            Mask(i,j) = Mask1(Ii)
            Perc(i,j) = Perc1(Ii)
            do m = 1, Mm
               Ival(m,i,j) = Ival1(m,Ii)
               Jval(m,i,j) = Jval1(m,Ii)
            end do
         end do

         write(*,*)'Finished Reading Merging Mask file'
         deallocate (Perc1)
         deallocate (Mask1)
         deallocate (I_lcal1)
         deallocate (j_lcal1)

      end if

      return
      end





