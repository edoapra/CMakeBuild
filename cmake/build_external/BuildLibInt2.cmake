
# This file will build LibInt

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

find_or_build_dependency(Eigen3)
package_dependency(Eigen3 DEPENDENCY_PATHS)
set(TEST_LIBINT FALSE)
if(${PROJECT_NAME} STREQUAL "TestBuildLibInt")
    set(TEST_LIBINT TRUE)
endif()

is_valid_and_true(LIBINT_URL __set)
if (NOT __set)
    set(LIBINT_URL https://github.com/ExaChem/exachem-support/raw/refs/heads/main/libint/libint-${CMSB_LIBINT_VERSION}.tar.xz)
endif()

set(LIBINT_TAR ${LIBINT_URL})

# append platform-specific optimization options for non-Debug builds
set(LIBINT_EXTRA_FLAGS "-Wno-unused-variable")
set(CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} ${LIBINT_EXTRA_FLAGS}")

if(ENABLE_OFFLINE_BUILD)
  set(LIBINT_TAR ${DEPS_LOCAL_PATH}/libint-${CMSB_LIBINT_VERSION}.tgz)
endif()

ExternalProject_Add(LibInt2_External
    URL ${LIBINT_TAR}
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DCMAKE_CXX_FLAGS_INIT=${CXX_FLAGS_INIT} -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
    INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
    CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
    ${CORE_CMAKE_STRINGS}
    )

add_dependencies(LibInt2_External Eigen3_External)

