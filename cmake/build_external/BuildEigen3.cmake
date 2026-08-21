include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

is_valid_and_true(EIGEN_TAG __et_set)
if(__et_set)
  set(EIGEN_GIT_TAG ${EIGEN_TAG})
endif()

# EIGEN_URL: override where Eigen3 sources come from. Accepts either:
#   - a git repository (https/git URL, or a path to a local git clone). This is
#     the default form; GIT_TAG (EIGEN_TAG/EIGEN_GIT_TAG) selects the revision.
#   - a source archive (.tar, .tar.gz, .tgz, .tar.xz, .tar.bz2, .zip, ...) or a
#     path/URL to one. No revision is checked out, so GIT_TAG does not apply.
is_valid_and_true(EIGEN_URL __eu_set)
if(NOT __eu_set)
  set(EIGEN_URL https://github.com/eigen-mirror/eigen)
endif()

if(EIGEN_URL MATCHES "\\.(tar|tar\\.gz|tgz|tar\\.xz|tar\\.bz2|tar\\.zst|zip)$")
  set(EIGEN_FETCH_ARGS URL ${EIGEN_URL})
else()
  set(EIGEN_FETCH_ARGS GIT_REPOSITORY ${EIGEN_URL} GIT_TAG ${EIGEN_GIT_TAG} UPDATE_DISCONNECTED 1)
endif()
# append platform-specific optimization options for non-Debug builds
set(EIGEN3_EXTRA_FLAGS "-DEIGEN_MAX_STATIC_ALIGN_BYTES=32")
set(CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} ${EIGEN3_EXTRA_FLAGS}")

if(ENABLE_OFFLINE_BUILD)
ExternalProject_Add(Eigen3_External
    SOURCE_DIR ${DEPS_LOCAL_PATH}/eigen
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
    )
else()
ExternalProject_Add(Eigen3_External
    ${EIGEN_FETCH_ARGS}
    CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DCMAKE_CXX_FLAGS_INIT=${CXX_FLAGS_INIT}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install #DESTDIR=${STAGE_DIR}
    )
endif()
