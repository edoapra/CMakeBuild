#!/bin/bash

set -eu
set -x

export cdir=`pwd`

# echo "Replace L20-21 in TAMM/CMakeLists.txt with: URL $cdir/CMakeBuild"
git clone https://github.com/NWChemEx-Project/CMakeBuild.git
cd CMakeBuild

cd $cdir

git clone https://github.com/wavefunction91/linalg-cmake-modules.git

git clone https://github.com/flame/blis.git
cd blis
git checkout 061c2ebef87eda9189e6cdf38af4ea3d4a8efe7b

cd $cdir

wget https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.34/OpenBLAS-0.3.34.tar.gz

wget https://github.com/doctest/doctest/archive/refs/tags/v2.4.11.tar.gz

wget https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/2026.02.002/elpa-2026.02.002.tar.gz

git clone https://gitlab.com/libeigen/eigen.git
cd eigen
git checkout 2265a5e025601d501903c772799ce29fb73c8efa

cd $cdir

git clone https://github.com/GlobalArrays/ga.git
cd ga
git checkout 635d6b341faf928cb5a0cddc38b1a0cbbc2b5bc4

cd $cdir
wget https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_1.14.4.3.tar.gz

git clone https://github.com/ajaypanyala/hptt.git
cd hptt
git checkout eff1bdd79734ddc4993dd4df1d0cdbd40758b9cb

cd $cdir
wget https://github.com/evaleev/libint/releases/download/v2.11.2/libint-2.11.2.tgz

git clone https://github.com/victor-anisimov/Librett.git
cd Librett
git checkout 45e83e1028fb722143b2d33a094be0e683af090b

cd $cdir

git clone https://github.com/Microsoft/GSL.git
cd GSL
git checkout 3325bbd33d24d1f8f5a0f69e782c92ad5a39a68e

cd $cdir

git clone https://github.com/nlohmann/json.git
cd json
git checkout v3.12.0

cd $cdir

git clone https://github.com/gabime/spdlog
cd spdlog
git checkout v1.15.2

cd $cdir

git clone https://github.com/Reference-LAPACK/lapack.git
cd lapack
git checkout 51b349470b3b26c948d068deb45c9b120a47ed32

cd $cdir
git clone https://github.com/Reference-ScaLAPACK/scalapack.git
cd scalapack
git checkout 7c58f784e4156d7b98bd0f154a69e5c2521e4a07

cd $cdir

git clone https://github.com/icl-utk-edu/blaspp
cd blaspp 
git checkout 148c4f8cae6e7eb1d2118039d564db10bdc25659

cd $cdir
git clone https://github.com/icl-utk-edu/lapackpp.git
cd lapackpp
git checkout 40b9d0daf29b6f1f3fa58bc3f22bd6cfb2c67fe4

cd $cdir
git clone https://github.com/wavefunction91/scalapackpp
cd scalapackpp
git checkout 6397f52cf11c0dfd82a79698ee198a2fce515d81
cd $cdir

git clone https://github.com/robashaw/libecpint.git
cd libecpint
git checkout 95203c68d1bb4134a235480d8c69c3014faaccf9

cd $cdir

git clone https://github.com/pybind/pybind11.git
cd pybind11
git checkout v3.1.0

cd $cdir

git clone https://github.com/pnnl/NWQ-Sim.git
cd NWQ-Sim
git checkout b35763d846e6512ed817d3f88ac8ce79a7e82a7e

cd $cdir
