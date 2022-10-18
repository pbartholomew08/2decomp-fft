!!!=======================================================================
!!! This is part of the 2DECOMP&FFT library
!!! 
!!! 2DECOMP&FFT is a software framework for general-purpose 2D (pencil) 
!!! decomposition. It also implements a highly scalable distributed
!!! three-dimensional Fast Fourier Transform (FFT).
!!!
!!! Copyright (C) 2022-     Xcompact3d developers
!!!
!!!=======================================================================

!!! Defines the kinds used by 2DECOMP&FFT
module decomp2d_kinds

  use, intrinsic :: iso_fortran_env, only : real32, real64
  use MPI
  
  implicit none

  private

#ifdef DOUBLE_PREC
  integer, parameter, public :: mytype = KIND(0._real64)
  integer, parameter, public :: real_type = MPI_DOUBLE_PRECISION
  integer, parameter, public :: real2_type = MPI_2DOUBLE_PRECISION
  integer, parameter, public :: complex_type = MPI_DOUBLE_COMPLEX
#ifdef SAVE_SINGLE
  integer, parameter, public :: mytype_single = KIND(0._real32)
  integer, parameter, public :: real_type_single = MPI_REAL
#else
  integer, parameter, public :: mytype_single = KIND(0._real64)
  integer, parameter, public :: real_type_single = MPI_DOUBLE_PRECISION
#endif
#else
  integer, parameter, public :: mytype = KIND(0._real32)
  integer, parameter, public :: real_type = MPI_REAL
  integer, parameter, public :: real2_type = MPI_2REAL
  integer, parameter, public :: complex_type = MPI_COMPLEX
  integer, parameter, public :: mytype_single = KIND(0._real32)
  integer, parameter, public :: real_type_single = MPI_REAL
#endif
  
end module decomp2d_kinds

