# Pin dependency versions

set(CMSB_HDF5_VERSION hdf5_1.14.4.3) #skip upto 1.14.6
set(CMSB_DOCTEST_VERSION 2.4.11)
set(CMSB_ELPA_VERSION 2026.02.002)

set(TAMM_GIT_TAG v0.1.0)
if(ENABLE_DEV_MODE OR USE_TAMM_DEV)
    set(TAMM_GIT_TAG main)
endif()

# numactl
set(NUMACTL_GIT_TAG v2.0.19)

# Eigen3
set(EIGEN_GIT_TAG 2265a5e025601d501903c772799ce29fb73c8efa) #April 23, 2025
if(ENABLE_DEV_MODE)
  set(EIGEN_GIT_TAG master)
endif()

# spdlog
set(SPDLOG_GIT_TAG v1.15.2)

# BLIS
set(BLIS_GIT_TAG 061c2ebef87eda9189e6cdf38af4ea3d4a8efe7b) #July 10, 2026
if(ENABLE_DEV_MODE)
  set(BLIS_GIT_TAG master)
endif()

# OpenBLAS
set(OpenBLAS_GIT_TAG 0.3.34)

# LAPACK
set(LAPACK_GIT_TAG 51b349470b3b26c948d068deb45c9b120a47ed32) #Aug 6, 2025
if(ENABLE_DEV_MODE)
  set(LAPACK_GIT_TAG master)
endif()

# ScaLAPACK
set(SL_GIT_TAG 7c58f784e4156d7b98bd0f154a69e5c2521e4a07) #July 10, 2025
if(ENABLE_DEV_MODE)
  set(SL_GIT_TAG master)
endif()

# NJSON
set(NJSON_GIT_TAG 3.12.0) #Do not use commit hash for NJSON
set(CMSB_NJSON_VERSION ${NJSON_GIT_TAG})

# GSL
set(MSGSL_GIT_TAG 3325bbd33d24d1f8f5a0f69e782c92ad5a39a68e) #4.2.0
if(ENABLE_DEV_MODE)
  set(MSGSL_GIT_TAG main)
endif()

# Global Arrays
set(GA_GIT_TAG 635d6b341faf928cb5a0cddc38b1a0cbbc2b5bc4) #Aug 12,2026
if(ENABLE_DEV_MODE)
  set(GA_GIT_TAG develop)
endif()

# HPTT
set(HPTT_GIT_TAG eff1bdd79734ddc4993dd4df1d0cdbd40758b9cb)
if(ENABLE_DEV_MODE)
  set(HPTT_GIT_TAG master)
endif()

# Librett
set(LIBRETT_GIT_TAG 45e83e1028fb722143b2d33a094be0e683af090b) #Aug 12, 2026
if(ENABLE_DEV_MODE)
  set(LIBRETT_GIT_TAG master)
endif()

# Libint
set(CMSB_LIBINT_VERSION 2.11.2) #2.9.0 is min

# LibEcpInt
set(ECPINT_GIT_TAG 95203c68d1bb4134a235480d8c69c3014faaccf9) #June 20, 2026
if(ENABLE_DEV_MODE)
  set(ECPINT_GIT_TAG master)
endif()

# GauXC
set(GXC_GIT_TAG 162e4562552323a871af17ae4acd73b71071bd24) #Aug 10, 2026
if(ENABLE_DEV_MODE)
    set(GXC_GIT_TAG master)
endif()

#NWQ-Sim
set(NWQSIM_GIT_TAG b35763d846e6512ed817d3f88ac8ce79a7e82a7e) #April 17, 2026
if(ENABLE_DEV_MODE)
  set(NWQSIM_GIT_TAG main)
endif()

set(PYBIND_GIT_TAG v3.1.0)
if(ENABLE_DEV_MODE)
  set(PYBIND_GIT_TAG master)
endif()

set(MACIS_GIT_TAG master)
if(ENABLE_DEV_MODE)
  set(MACIS_GIT_TAG master)
endif()
