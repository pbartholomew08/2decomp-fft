### src/fft/CMakeLists.txt --- CMake file for the FFT module
#
# SPDX-License-Identifier: BSD-3-Clause 

file(GLOB files_fft fft.f90)

if(FFTW_FOUND)
  if (${FFT_Choice} MATCHES "fftw_f03")
    message (STATUS "Compiling using FFTW3 F2003 interface")
    list(APPEND files_fft fft_fftw3_f03.f90)
  else()
    message (STATUS "Compiling using FFTW3 legacy interface")
    list(APPEND files_fft fft_fftw3.f90)
  endif()
elseif(MKL_FOUND)
  message (STATUS "Compiling using MKL")
  list(APPEND files_fft $ENV{MKLROOT}/include/mkl_dfti.f90 fft_mkl.f90)
elseif(CUFFT_FOUND)
  message (STATUS "Compiling using cuFFT")
  list(APPEND files_fft fft_cufft.f90)
else(FFTW_FOUND)
  message (STATUS "Compiling using Generic FFT")
  list(APPEND files_fft fft_common_3d.f90 fft_generic.f90 glassman.f90)
endif(FFTW_FOUND)
list(APPEND files_fft fft_log.f90)

# Build a CMake object library for the FFT module
add_library(decomp2d_fft OBJECT ${files_fft})
target_link_libraries(decomp2d_fft PUBLIC $<TARGET_OBJECTS:decomp2d_core>) # "Link" the core code

target_include_directories(decomp2d_fft PUBLIC
  $<BUILD_INTERFACE:${CMAKE_Fortran_MODULE_DIRECTORY}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

if(FFTW_FOUND)
  if (FFTW_DOUBLE_LIB_FOUND)
    message(STATUS "FFTW_DOUBLE     : ${FFTW_DOUBLE_LIB}")
    target_link_libraries(decomp2d_fft PRIVATE ${FFTW_DOUBLE_LIB})
  endif (FFTW_DOUBLE_LIB_FOUND)
  if (FFTW_FLOAT_LIB_FOUND)
    message(STATUS "FFTW_SINGLE     : ${FFTW_FLOAT_LIB}")
    target_link_libraries(decomp2d_fft PRIVATE ${FFTW_FLOAT_LIB})
  endif (FFTW_FLOAT_LIB_FOUND)
  if (NOT (FFTW_DOUBLE_LIB_FOUND OR FFTW_FLOAT_LIB_FOUND))
    message(FATAL_ERROR "CMake step for FFTW failed")
  endif (NOT (FFTW_DOUBLE_LIB_FOUND OR FFTW_FLOAT_LIB_FOUND))
  target_include_directories(decomp2d_fft PRIVATE ${FFTW_INCLUDE_DIRS})
elseif(MKL_FOUND)
  target_compile_options(decomp2d_fft PUBLIC $<TARGET_PROPERTY:MKL::MKL,INTERFACE_COMPILE_OPTIONS>)
  target_include_directories(decomp2d_fft PUBLIC $<TARGET_PROPERTY:MKL::MKL,INTERFACE_INCLUDE_DIRECTORIES>)
  target_link_libraries(decomp2d_fft PUBLIC $<LINK_ONLY:MKL::MKL>)
endif(FFTW_FOUND)

# This can probably be tidied up (repeated from parent CMake file)
if (MPI_FOUND)
  target_link_libraries(decomp2d_fft PRIVATE MPI::MPI_Fortran)
endif (MPI_FOUND)

if (ENABLE_PROFILER)
  target_compile_definitions(decomp2d_fft PUBLIC -DPROFILER)

  if (caliper_FOUND)
    target_include_directories(decomp2d_fft PUBLIC ${caliper_INCLUDE_DIR}/caliper/fortran)
    target_link_libraries(decomp2d_fft PRIVATE caliper)
  endif()
endif()

if (HALO_DEBUG)
  target_compile_definitions(decomp2d_fft PUBLIC -DHALO_DEBUG)
endif()

if (IO_BACKEND MATCHES "adios2")
  target_compile_definitions(decomp2d_fft PUBLIC -DADIOS2)
  target_link_libraries(decomp2d_fft PUBLIC adios2::fortran_mpi adios2::fortran)
endif (IO_BACKEND MATCHES "adios2")
