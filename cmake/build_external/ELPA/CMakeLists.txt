cmake_minimum_required(VERSION ${CMAKE_VERSION})
project(ELPA VERSION ${CMSB_ELPA_VERSION} LANGUAGES C CXX Fortran)

include(DependencyMacros)
include(ExternalProject)

function(makify_deps __dep_libs __make_dep_libs __prefer_static __add_rpath)
    set(_lib_path_final)
    foreach(__lib ${${__dep_libs}})
        # Remove the actual library from the path
        get_filename_component(_lib_path ${__lib} DIRECTORY)
        # Get only library name with extension
        get_filename_component(_name_lib ${__lib} NAME_WE)
        if(NOT _lib_path STREQUAL "")
            #TODO:append if unique
            # set(_lib_path_final "-L${_lib_path}")
            # Strip the lib prefix
            string(SUBSTRING ${_name_lib} 3 -1 _name_lib)
            set(_rpath_flag)
            if(${__add_rpath})
              set(_rpath_flag "-Wl,-rpath,${_lib_path}")
            endif()
            if(${__prefer_static})
              set(${__make_dep_libs} "-L${_lib_path} ${_rpath_flag} ${${__make_dep_libs}} -Wl,-Bstatic -l${_name_lib}")
            else()
              set(${__make_dep_libs} "-L${_lib_path} ${_rpath_flag} ${${__make_dep_libs}} -l${_name_lib}")
            endif()
        endif()
    endforeach()
    # set(${__make_dep_libs} "${_lib_path_final} ${${__make_dep_libs}}")
    set(${__make_dep_libs} ${${__make_dep_libs}} PARENT_SCOPE)
endfunction()

find_package(MPI REQUIRED)

foreach(CMSB_MPI_lang C Fortran)
is_valid_and_true(MPI_${CMSB_MPI_lang}_FOUND CMSB_MPI_was_found)
    if(CMSB_MPI_was_found)
        list(APPEND CMSB_MPI_LIBRARIES
                    ${MPI_${CMSB_MPI_lang}_LIBRARIES})
        list(APPEND CMSB_MPI_INCLUDE_DIRS
                    ${MPI_${CMSB_MPI_lang}_INCLUDE_DIRS})

        if (NOT "${MPI_${CMSB_MPI_lang}_COMPILE_FLAGS}" STREQUAL "")
            string(REPLACE " " ";" REPLACED_MPI_${CMSB_MPI_lang}_COMPILE_FLAGS ${MPI_${CMSB_MPI_lang}_COMPILE_FLAGS})
            set(MPI_${CMSB_MPI_lang}_COMPILE_FLAGS ${REPLACED_MPI_${CMSB_MPI_lang}_COMPILE_FLAGS})
        endif()

        #list(APPEND CMSB_MPI_DEFINITIONS
        #            ${MPI_${CMSB_MPI_lang}_COMPILE_FLAGS})
        list(APPEND CMSB_MPI_LINK_FLAGS
                    ${MPI_${CMSB_MPI_lang}_LINK_FLAGS})
        set(CMSB_MPI_FOUND TRUE)
    endif()
endforeach()

list(REMOVE_DUPLICATES CMSB_MPI_LIBRARIES)
list(REMOVE_DUPLICATES CMSB_MPI_INCLUDE_DIRS)
list(REMOVE_DUPLICATES CMSB_MPI_DEFINITIONS)
list(REMOVE_DUPLICATES CMSB_MPI_LINK_FLAGS)

string_concat(CMSB_MPI_INCLUDE_DIRS "-I" " " elpa_mpi_incs)
makify_deps(CMSB_MPI_LIBRARIES elpa_mpi_libs OFF OFF)

# if(DEFINED TAMM_EXTRA_LIBS)
#     set(GA_CMSB_EXTRA_LIBS "-DGA_EXTRA_LIBS=${TAMM_EXTRA_LIBS}")
# endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/../cmsb_linalg.cmake)

find_package(ScaLAPACK)
if (NOT ScaLAPACK_FOUND)
    message(FATAL_ERROR "ENABLE_SCALAPACK=ON, but a ScaLAPACK library was not found")
endif()

find_package(LAPACK)
if (NOT LAPACK_FOUND)
    message(FATAL_ERROR "ENABLE_LAPACK=ON, but a LAPACK library was not found")
endif()

find_package(BLAS)
if (NOT BLAS_FOUND)
    message(FATAL_ERROR "ENABLE_BLAS=ON, but a BLAS library was not found")
endif()

string_concat(CMAKE_C_FLAGS_RELEASE "" " " ELPA_C_FLAGS)
string_concat(CMAKE_Fortran_FLAGS_RELEASE "" " " ELPA_F_FLAGS)

# TODO: check
# if(CMAKE_POSITION_INDEPENDENT_CODE)
#     set(FPIC_LIST "-fPIC")
#     string_concat(FPIC_LIST "" " " ELPA_C_FLAGS)
#     string_concat(FPIC_LIST "" " " ELPA_F_FLAGS)
# endif()

message(STATUS "sca: ${ScaLAPACK_LIBRARIES}")
message(STATUS "lapack: ${LAPACK_LIBRARIES}")
message(STATUS "blas: ${BLAS_LIBRARIES}")

#TODO: more robust cray detection
if(DEFINED ENV{CRAYPE_VERSION})
  makify_deps(ScaLAPACK_LIBRARIES elpa_scalapack_libs ON OFF)
  makify_deps(LAPACK_LIBRARIES elpa_lapack_libs ON OFF)
  makify_deps(BLAS_LIBRARIES elpa_blas_libs ON OFF)
  set(ELPA_SHARED_LIBS --disable-shared)
  set(ELPA_CRAY_DYN -Wl,-Bdynamic)
else()
  makify_deps(ScaLAPACK_LIBRARIES elpa_scalapack_libs OFF ON)
  makify_deps(LAPACK_LIBRARIES elpa_lapack_libs OFF ON)
  makify_deps(BLAS_LIBRARIES elpa_blas_libs OFF ON)
endif()

set(ELPA_F_FLAGS "${ELPA_F_FLAGS} ${elpa_mpi_incs}")
set(ELPA_LINALG "LIBS=${elpa_scalapack_libs} ${elpa_lapack_libs} ${elpa_blas_libs} ${elpa_mpi_libs}")
set(ELPA_INTRINSICS --disable-sve512 --disable-avx512 --disable-openmp --disable-detect-mpi-launcher)

if(${CMSB_PROJECTS}_HAS_CUDA)
  find_package(CUDAToolkit REQUIRED)
  get_filename_component(__cuda_install_prefix "${CUDAToolkit_INCLUDE_DIRS}/.." ABSOLUTE)
  #TODO: fix -lstdc++
  set(ELPA_LINALG "LIBS=${elpa_scalapack_libs} ${elpa_lapack_libs} ${elpa_blas_libs} ${elpa_mpi_libs} ${ELPA_CRAY_DYN} -lcublasLt -lstdc++")
  set(ELPA_GPU --disable-c-tests --disable-cpp-tests --enable-nvidia-gpu-kernels --with-NVIDIA-GPU-compute-capability=sm_${GPU_ARCH}  --with-cuda-path=${__cuda_install_prefix})
endif()

message(STATUS "ELPA configure options: 
        ./configure --prefix=${CMAKE_INSTALL_PREFIX}
        ${ELPA_INTRINSICS}
        ${ELPA_SHARED_LIBS}
        ${ELPA_GPU}
        CXX=${CMAKE_CXX_COMPILER}
        CC=${CMAKE_C_COMPILER}
        FC=${CMAKE_Fortran_COMPILER}
        CFLAGS=${ELPA_C_FLAGS}
        FCFLAGS=${ELPA_F_FLAGS}
        CPPFLAGS=${elpa_mpi_incs}
        ${ELPA_LINALG}"
        )

is_valid_and_true(ELPA_URL __set)
if (NOT __set)
  set(_ELPA_URL "https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/${CMSB_ELPA_VERSION}/elpa-${CMSB_ELPA_VERSION}.tar.gz")
else()
    set(_ELPA_URL ${ELPA_URL})
endif()

if(ENABLE_OFFLINE_BUILD)

ExternalProject_Add(ELPA_External
    URL ${DEPS_LOCAL_PATH}/elpa-${CMSB_ELPA_VERSION}.tar.gz
    PATCH_COMMAND find . -exec touch -c {} +
    CONFIGURE_COMMAND ACLOCAL=true AUTOMAKE=true AUTOCONF=true AUTOHEADER=true MAKEINFO=true
                                    ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                    ${ELPA_INTRINSICS}
                                    ${ELPA_SHARED_LIBS}
                                    ${ELPA_GPU}
                                    CXX=${CMAKE_CXX_COMPILER}
                                    CC=${CMAKE_C_COMPILER}
                                    FC=${CMAKE_Fortran_COMPILER}
                                    CFLAGS=${ELPA_C_FLAGS}
                                    FCFLAGS=${ELPA_F_FLAGS}
                                    CPPFLAGS=${elpa_mpi_incs}
                                    ${ELPA_LINALG}

    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    BUILD_IN_SOURCE 1
)

else()
ExternalProject_Add(ELPA_External
    URL ${_ELPA_URL}
    PATCH_COMMAND find . -exec touch -c {} +
    CONFIGURE_COMMAND ACLOCAL=true AUTOMAKE=true AUTOCONF=true AUTOHEADER=true MAKEINFO=true
                                    ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                    ${ELPA_INTRINSICS}
                                    ${ELPA_SHARED_LIBS}
                                    ${ELPA_GPU}
                                    CXX=${CMAKE_CXX_COMPILER}
                                    CC=${CMAKE_C_COMPILER}
                                    FC=${CMAKE_Fortran_COMPILER}
                                    CFLAGS=${ELPA_C_FLAGS}
                                    FCFLAGS=${ELPA_F_FLAGS}
                                    CPPFLAGS=${elpa_mpi_incs}
                                    ${ELPA_LINALG}
                                    
                                    
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    BUILD_IN_SOURCE 1
)
endif()

