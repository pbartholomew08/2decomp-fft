!!!=======================================================================
!!! This is part of the 2DECOMP&FFT library
!!! 
!!! 2DECOMP&FFT is a software framework for general-purpose 2D (pencil) 
!!! decomposition. It also implements a highly scalable distributed
!!! three-dimensional Fast Fourier Transform (FFT).
!!!
!!! Copyright (C) 2022-     The Xcompact3d developers
!!!
!!!=======================================================================

module decomp_2d_types

  implicit none

  private

#ifdef SHM
  ! derived type to store shared-memory info
  TYPE, public :: SMP_INFO
     integer MPI_COMM          ! SMP associated with this communicator
     integer NODE_ME           ! rank in this communicator
     integer NCPU              ! size of this communicator
     integer SMP_COMM          ! communicator for SMP-node masters
     integer CORE_COMM         ! communicator for cores on SMP-node
     integer SMP_ME            ! SMP-node id starting from 1 ... NSMP
     integer NSMP              ! number of SMP-nodes in this communicator
     integer CORE_ME           ! core id starting from 1 ... NCORE
     integer NCORE             ! number of cores on this SMP-node
     integer MAXCORE           ! maximum no. cores on any SMP-node
     integer N_SND             ! size of SMP shared memory buffer
     integer N_RCV             ! size of SMP shared memory buffer
     integer(8) SND_P          ! SNDBUF address (cray pointer), for real 
     integer(8) RCV_P          ! RCVBUF address (cray pointer), for real
     integer(8) SND_P_c        ! for complex
     integer(8) RCV_P_c        ! for complex
  END TYPE SMP_INFO
#endif

  ! derived type to store decomposition info for a given global data size
  TYPE, public :: DECOMP_INFO
     ! staring/ending index and size of data held by current processor
     integer, dimension(3) :: xst, xen, xsz  ! x-pencil
     integer, dimension(3) :: yst, yen, ysz  ! y-pencil
     integer, dimension(3) :: zst, zen, zsz  ! z-pencil

     ! in addition to local information, processors also need to know 
     ! some global information for global communications to work 

     ! how each dimension is distributed along pencils
     integer, allocatable, dimension(:) :: &
          x1dist, y1dist, y2dist, z2dist

     ! send/receive buffer counts and displacements for MPI_ALLTOALLV
     integer, allocatable, dimension(:) :: &
          x1cnts, y1cnts, y2cnts, z2cnts
     integer, allocatable, dimension(:) :: &
          x1disp, y1disp, y2disp, z2disp

     ! buffer counts for MPI_ALLTOALL: either for evenly distributed data
     ! or for padded-alltoall
     integer :: x1count, y1count, y2count, z2count

     ! evenly distributed data
     logical :: even

#ifdef SHM
     ! For shared-memory implementation

     ! one instance of this derived type for each communicator
     ! shared moemory info, such as which MPI rank belongs to which node
     TYPE(SMP_INFO) :: ROW_INFO, COL_INFO

     ! shared send/recv buffers for ALLTOALLV
     integer, allocatable, dimension(:) :: x1cnts_s, y1cnts_s, &
          y2cnts_s, z2cnts_s
     integer, allocatable, dimension(:) :: x1disp_s, y1disp_s, &
          y2disp_s, z2disp_s
     ! A copy of original buffer displacement (will be overwriten)
     integer, allocatable, dimension(:) :: x1disp_o, y1disp_o, &
          y2disp_o, z2disp_o
#endif
  END TYPE DECOMP_INFO
  
end module decomp_2d_types
