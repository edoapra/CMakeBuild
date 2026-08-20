
#
# This file will build BLIS which is the default BLAS library we use.
#

enable_language(C Fortran)

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

is_valid_and_true(BLAS_ARCH __blas_arch_set)
if (NOT __blas_arch_set)
  message(STATUS "BLAS_ARCH not set, will auto-detect")
else()
  message(STATUS "BLAS_ARCH set to ${BLAS_ARCH}")
  set(__BLAS_ARCH ${BLAS_ARCH})
endif()

if("${LINALG_VENDOR}" STREQUAL "BLIS")

if (NOT __blas_arch_set)
  set(__BLAS_ARCH "auto")
endif()

string_concat(CMAKE_C_FLAGS_RELEASE "" " " BLIS_FLAGS)

if(CMAKE_POSITION_INDEPENDENT_CODE)
    set(FPIC_LIST "-fPIC")
    string_concat(FPIC_LIST "" " " BLIS_FLAGS)
endif()

# set(BLIS_TAR https://github.com/flame/blis/archive/refs/tags/0.9.0.tar.gz)

is_valid_and_true(BLIS_TAG __lt_set)
if(__lt_set)
  set(BLIS_GIT_TAG ${BLIS_TAG})
endif()

set(BLIS_OPT_FLAGS "${BLIS_FLAGS}")

# set(BLIS_W_OPENMP no)
# if(USE_OPENMP) #Requires FindRefBLAS to find openmp if enabled
#   set(BLIS_W_OPENMP openmp)
# endif()

set(BLIS_INT_FLAGS -i 64 -b 64 --enable-cblas)

if(BLAS_INT4)
    set(BLIS_INT_FLAGS -i 32 -b 32 --enable-cblas)
endif()

set(BLIS_MISC_OPTIONS --without-memkind --enable-scalapack-compat)

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(BLAS_External
        SOURCE_DIR ${DEPS_LOCAL_PATH}/blis
        CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                      CXX=${CMAKE_CXX_COMPILER}
                                      CC=${CMAKE_C_COMPILER}
                                      CFLAGS=${BLIS_OPT_FLAGS}
                                      ${BLIS_INT_FLAGS}
                                      ${BLIS_MISC_OPTIONS}
                                      ${__BLAS_ARCH}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR} 
        BUILD_IN_SOURCE 1
)
else()
ExternalProject_Add(BLAS_External
        GIT_REPOSITORY https://github.com/flame/blis.git
        GIT_TAG ${BLIS_GIT_TAG}
        UPDATE_DISCONNECTED 1
        CONFIGURE_COMMAND ./configure --prefix=${CMAKE_INSTALL_PREFIX}
                                      CXX=${CMAKE_CXX_COMPILER}
                                      CC=${CMAKE_C_COMPILER}
                                      CFLAGS=${BLIS_OPT_FLAGS}
                                      ${BLIS_INT_FLAGS}
                                      ${BLIS_MISC_OPTIONS}
                                      ${__BLAS_ARCH}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR} 
        BUILD_IN_SOURCE 1
)
endif()


elseif("${LINALG_VENDOR}" STREQUAL "OpenBLAS")

set(OB_INT8 OFF)

if(NOT BLAS_INT4)
  set(OB_INT8 ON)
endif()

if (__blas_arch_set)
  set(OPENBLAS_TARGET_ARCH "-DTARGET=${__BLAS_ARCH}")
endif()

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(BLAS_External
        URL ${DEPS_LOCAL_PATH}/OpenBLAS-${OpenBLAS_GIT_TAG}.tar.gz
        CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
                                      -DBUILD_WITHOUT_LAPACK=ON
                                      ${OPENBLAS_TARGET_ARCH}
                                      -DBUILD_TESTING=OFF
                                      -DBUILD_WITHOUT_CBLAS=ON
                                      -DINTERFACE64=${OB_INT8}#			      -DDYNAMIC_ARCH=ON
				      -DTARGET=HASWELL
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
        BUILD_IN_SOURCE 1
)
else()
ExternalProject_Add(BLAS_External
        URL https://github.com/OpenMathLib/OpenBLAS/releases/download/v${OpenBLAS_GIT_TAG}/OpenBLAS-${OpenBLAS_GIT_TAG}.tar.gz
        CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
                                      -DBUILD_WITHOUT_LAPACK=ON
                                      ${OPENBLAS_TARGET_ARCH}
                                      -DBUILD_TESTING=OFF
                                      -DBUILD_WITHOUT_CBLAS=ON # -DDYNAMIC_ARCH=ON
				      -DTARGET=HASWELL
                                      -DINTERFACE64=${OB_INT8}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
        BUILD_IN_SOURCE 1
)
endif()

endif()
