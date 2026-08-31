#
# This file builds Global Arrays.
#
include(UtilityMacros)
include(DependencyMacros)

enable_language(Fortran)

include(${CMAKE_CURRENT_LIST_DIR}/dep_versions.cmake)

    is_valid_and_true(GA_RUNTIME __set)
    if (NOT __set)
        message(STATUS "ARMCI network not set, defaulting to MPI_PROGRESS_RANK")
        set(GA_RUNTIME MPI_PROGRESS_RANK)
    endif()

    is_valid_and_true(GA_URL __set)
    if (NOT __set)
      set(GA_URL "https://github.com/GlobalArrays/ga.git")
    endif()

    is_valid_and_true(GA_TAG __set)
    if(__set)
      set(GA_GIT_TAG ${GA_TAG})
    endif()

    if(GCCROOT)
        set(Clang_GCCROOT "-DGCCROOT=${GCCROOT}")
    endif()

    is_valid_and_true(GA_ENABLE_SYSV __set)
    if (NOT __set)
        set(GA_ENABLE_SYSV OFF)
    endif()    

    # if(DEFINED TAMM_EXTRA_LIBS)
    #     set(GA_CMSB_EXTRA_LIBS "-DGA_EXTRA_LIBS=${TAMM_EXTRA_LIBS}")
    # endif()


    if(BLAS_INT4)
        set(LINALG_REQUIRED_COMPONENTS "lp64")
    else()
        set(LINALG_REQUIRED_COMPONENTS "ilp64")
    endif()

    if("${LINALG_VENDOR}" STREQUAL "IntelMKL")
        set(LINALG_THREAD_LAYER "sequential")
        if(USE_OPENMP)
            set(LINALG_THREAD_LAYER "openmp")
        endif()
    elseif("${LINALG_VENDOR}" STREQUAL "IBMESSL")
        set(LINALG_THREAD_LAYER "serial")
        if(USE_OPENMP)
            set(LINALG_THREAD_LAYER "smp")
        endif()
    endif()

    if(LINALG_THREAD_LAYER)
      set(GA_LINALG_THREAD_LAYER "-DLINALG_THREAD_LAYER=${LINALG_THREAD_LAYER}")
    endif()

    set(GA_LINALG_ROOT   "-DLINALG_PREFIX=${LINALG_PREFIX}")

    if(${LINALG_VENDOR} STREQUAL "BLIS" OR ${LINALG_VENDOR} STREQUAL "OpenBLAS" OR ${LINALG_VENDOR} STREQUAL "IBMESSL")
        set(BLAS_PREFERENCE_LIST ${LINALG_VENDOR})
        set(LAPACK_PREFERENCE_LIST ReferenceLAPACK)

        set(LINALG_PREFER_STATIC ON)
        if(BUILD_SHARED_LIBS)
          set(LINALG_PREFER_STATIC OFF)
        endif()
        set(${LINALG_VENDOR}_PREFERS_STATIC    ${LINALG_PREFER_STATIC})
        set(ReferenceLAPACK_PREFERS_STATIC     ${LINALG_PREFER_STATIC})
        set(ReferenceScaLAPACK_PREFERS_STATIC  ${LINALG_PREFER_STATIC})
    
        set(${LINALG_VENDOR}_THREAD_LAYER  ${LINALG_THREAD_LAYER})
        set(BLAS_REQUIRED_COMPONENTS       ${LINALG_REQUIRED_COMPONENTS})
        set(LAPACK_REQUIRED_COMPONENTS     ${LINALG_REQUIRED_COMPONENTS})
        set(ScaLAPACK_REQUIRED_COMPONENTS  ${LINALG_REQUIRED_COMPONENTS})

        if(${LINALG_VENDOR} STREQUAL "BLIS" OR ${LINALG_VENDOR} STREQUAL "OpenBLAS")
            set(GA_LINALG_ROOT   "-DLINALG_PREFIX=${CMAKE_INSTALL_PREFIX}")
        endif()

        if(USE_SCALAPACK)
            set(ScaLAPACK_PREFERENCE_LIST ReferenceScaLAPACK)
            find_or_build_dependency(LAPACK)	    
            find_or_build_dependency(ScaLAPACK)
            list(APPEND  GA_LINALG_ROOT "-DScaLAPACK_PREFIX=${CMAKE_INSTALL_PREFIX}")
        else()
            find_or_build_dependency(LAPACK)
            if(TARGET BLAS_External)
                find_or_build_dependency(BLAS)
            endif()
            #include(BuildBLAS)
        endif()

        list(APPEND  GA_LINALG_ROOT "-DLAPACK_PREFIX=${CMAKE_INSTALL_PREFIX}")
    endif()

    if(USE_SCALAPACK)
      set(GA_ScaLAPACK "-DENABLE_SCALAPACK=ON")
    endif()

    if(${CMSB_PROJECTS}_HAS_DPCPP)
      set(GA_DPCPP "-DENABLE_DPCPP=ON")
    endif()

    if(ENABLE_DEV_MODE)
      set(GA_DEV_MODE "-DENABLE_DEV_MODE=ON")
    endif()

    if(ENABLE_COVERAGE)
      set(ENABLE_COVERAGE "-DENABLE_COVERAGE=ON")
    else()
      set(ENABLE_COVERAGE)
    endif()

    if(${CMSB_PROJECTS}_HAS_HIP)
      set(ENABLE_HIP -DENABLE_HIP=ON -DCMAKE_HIP_ARCHITECTURES=${GPU_ARCH})
    elseif(${CMSB_PROJECTS}_HAS_CUDA)
      set(ENABLE_CUDA -DENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=${GPU_ARCH})
    endif()

    if(ENABLE_OFFLINE_BUILD)
      set(ENABLE_GA_LOCAL_BUILD -DENABLE_OFFLINE_BUILD=ON -DDEPS_LOCAL_PATH=${DEPS_LOCAL_PATH})
    endif()

    message(STATUS "GlobalArrays CMake Options: ${DEPENDENCY_CMAKE_OPTIONS} \
    -DENABLE_BLAS=ON -DLINALG_VENDOR=${LINALG_VENDOR} ${GA_LINALG_ROOT} \
    ${GA_DPCPP} -DGA_RUNTIME=${GA_RUNTIME} -DENABLE_SYSV=${GA_ENABLE_SYSV} \
    -DENABLE_PROFILING=${USE_GA_PROFILER} ${GA_CMSB_EXTRA_LIBS} \
    ${Clang_GCCROOT} ${GA_LINALG_THREAD_LAYER} ${GA_DEV_MODE} \
    -DLINALG_REQUIRED_COMPONENTS=${LINALG_REQUIRED_COMPONENTS} ${GA_ScaLAPACK} \
    ${ENABLE_CUDA} ${ENABLE_HIP} ${ENABLE_COVERAGE} ${ENABLE_GA_LOCAL_BUILD}")

    if(ENABLE_OFFLINE_BUILD)
    ExternalProject_Add(GlobalArrays_External
        SOURCE_DIR ${DEPS_LOCAL_PATH}/ga
        CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DENABLE_BLAS=ON -DLINALG_VENDOR=${LINALG_VENDOR} ${GA_LINALG_ROOT} 
        ${GA_DPCPP} -DGA_RUNTIME=${GA_RUNTIME} -DENABLE_SYSV=${GA_ENABLE_SYSV} -DENABLE_PROFILING=${USE_GA_PROFILER} 
        ${GA_LINALG_THREAD_LAYER} -DLINALG_REQUIRED_COMPONENTS=${LINALG_REQUIRED_COMPONENTS} ${GA_ScaLAPACK} ${GA_DEV_MODE} 
        ${GA_CMSB_EXTRA_LIBS} ${Clang_GCCROOT} ${ENABLE_CUDA} ${ENABLE_HIP} ${ENABLE_COVERAGE} ${ENABLE_GA_LOCAL_BUILD}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
        CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
                        ${CORE_CMAKE_STRINGS}
    )
    else()
    ExternalProject_Add(GlobalArrays_External
        # URL https://github.com/GlobalArrays/ga/releases/download/v${PROJECT_VERSION}/ga-${PROJECT_VERSION}.tar.gz
        GIT_REPOSITORY ${GA_URL}
        GIT_TAG ${GA_GIT_TAG}
        UPDATE_DISCONNECTED 1
        CMAKE_ARGS ${DEPENDENCY_CMAKE_OPTIONS} -DENABLE_BLAS=ON -DLINALG_VENDOR=${LINALG_VENDOR} ${GA_LINALG_ROOT} 
        ${GA_DPCPP} -DGA_RUNTIME=${GA_RUNTIME} -DENABLE_SYSV=${GA_ENABLE_SYSV} -DENABLE_PROFILING=${USE_GA_PROFILER} 
        ${GA_LINALG_THREAD_LAYER} -DLINALG_REQUIRED_COMPONENTS=${LINALG_REQUIRED_COMPONENTS} ${GA_ScaLAPACK} ${GA_DEV_MODE} 
        ${GA_CMSB_EXTRA_LIBS} ${Clang_GCCROOT} ${ENABLE_CUDA} ${ENABLE_HIP} ${ENABLE_COVERAGE}
        INSTALL_COMMAND ${CMAKE_MAKE_PROGRAM} install DESTDIR=${STAGE_DIR}
        CMAKE_CACHE_ARGS ${CORE_CMAKE_LISTS}
                        ${CORE_CMAKE_STRINGS}
    )
    endif()
    
    # Establish the dependencies
    if(${LINALG_VENDOR} STREQUAL "BLIS" OR ${LINALG_VENDOR} STREQUAL "IBMESSL" OR ${LINALG_VENDOR} STREQUAL "OpenBLAS")
        if(${LINALG_VENDOR} STREQUAL "BLIS" OR ${LINALG_VENDOR} STREQUAL "OpenBLAS")
            add_dependencies(GlobalArrays_External BLAS_External LAPACK_External)
        elseif(${LINALG_VENDOR} STREQUAL "IBMESSL")
            add_dependencies(GlobalArrays_External LAPACK_External)
        endif()
        if(USE_SCALAPACK)
            add_dependencies(GlobalArrays_External ScaLAPACK_External)
        endif()
    endif()



