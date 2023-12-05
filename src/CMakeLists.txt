file(GLOB files_decomp factor.f90
	               decomp_2d_constants.f90
		       decomp_2d_mpi.f90
	               decomp_2d.f90
		       log.f90
		       io.f90)
include_directories(${CMAKE_SOURCE_DIR}/src)

if(${BUILD_TARGET} MATCHES "gpu")
  list(APPEND files_decomp decomp_2d_cumpi.f90)
  if(ENABLE_NCCL)
    list(APPEND files_decomp decomp_2d_nccl.f90)
  endif()
endif(${BUILD_TARGET} MATCHES "gpu")

if (ENABLE_PROFILER)
  file(GLOB prof_files profiler_${ENABLE_PROFILER}.f90)
endif()

# Build the FFT module
add_subdirectory(fft)

set(SRCFILES ${files_decomp} ${prof_files})

add_library(decomp2d ${SRCFILES})
target_link_libraries(decomp2d PUBLIC $<TARGET_OBJECTS:decomp2d_fft>) # "Link" the FFT module

target_include_directories(decomp2d PUBLIC
  $<BUILD_INTERFACE:${CMAKE_Fortran_MODULE_DIRECTORY}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
if (MPI_FOUND)
  target_link_libraries(decomp2d PRIVATE MPI::MPI_Fortran)
endif (MPI_FOUND)

if (ENABLE_PROFILER)
  target_compile_definitions(decomp2d PUBLIC -DPROFILER)

  if (caliper_FOUND)
    target_include_directories(decomp2d PUBLIC ${caliper_INCLUDE_DIR}/caliper/fortran)
    target_link_libraries(decomp2d PRIVATE caliper)
  endif()
endif()

if (HALO_DEBUG)
  target_compile_definitions(decomp2d PUBLIC -DHALO_DEBUG)
endif()

if (IO_BACKEND MATCHES "adios2")
  target_compile_definitions(decomp2d PUBLIC -DADIOS2)
  target_link_libraries(decomp2d PUBLIC adios2::fortran_mpi adios2::fortran)
endif (IO_BACKEND MATCHES "adios2")

install(TARGETS decomp2d
  EXPORT decomp2d-targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING PATTERN "*.mod")
install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING PATTERN "*.smod")
      
## Packaging
install(EXPORT decomp2d-targets
  DESTINATION ${CMAKE_INSTALL_LIBDIR})

configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/decomp2d-config.cmake.in
  ${PROJECT_BINARY_DIR}/cmake/decomp2d-config.cmake @ONLY
)
configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/decomp2d-config-version.cmake.in
  ${PROJECT_BINARY_DIR}/cmake/decomp2d-config-version.cmake
)

install(FILES
  ${PROJECT_BINARY_DIR}/cmake/decomp2d-config.cmake
  ${PROJECT_BINARY_DIR}/cmake/decomp2d-config-version.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/decomp2d)

# Make 2decomp usable from build tree.
export(TARGETS decomp2d
  FILE ${PROJECT_BINARY_DIR}/decomp2d-targets.cmake)
configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/decomp2d-build_config.cmake.in
  ${PROJECT_BINARY_DIR}/decomp2d-config.cmake @ONLY
)
