#!/bin/bash

if [[ $OS_NAME == "macos" ]] && [[ $COMPILER == "gcc" ]]; then
    export CXX=g++-9
    export CC=gcc-9
elif [[ $OS_NAME == "linux" ]] && [[ $COMPILER == "clang" ]]; then
    export CXX=clang++
    export CC=clang
fi

if [[ $OS_NAME == "macos" ]] && [[ $COMPILER == "clang" ]] && [[ $(sw_vers -productVersion | cut -d'.' -f2) -ge "14" ]]; then
    CMAKE_OPTS=(-DOpenMP_C_FLAGS="-Xpreprocessor -fopenmp -I$(brew --prefix libomp)/include"
                -DOpenMP_C_LIB_NAMES=omp
                -DOpenMP_CXX_FLAGS="-Xpreprocessor -fopenmp -I$(brew --prefix libomp)/include"
                -DOpenMP_CXX_LIB_NAMES=omp
                -DOpenMP_omp_LIBRARY=$(brew --prefix libomp)/lib/libomp.dylib)
else
    CMAKE_OPTS=()
fi

conda create -q -y -n $CONDA_ENV python=$PYTHON_VERSION
source activate $CONDA_ENV

cd $BUILD_DIRECTORY

conda install -q -y -n $CONDA_ENV joblib matplotlib numpy pandas psutil pytest python-graphviz scikit-learn scipy
pip install lightgbm catboost

if [[ $OS_NAME == "macos" ]] && [[ $COMPILER == "clang" ]]; then
    # fix "OMP: Error #15: Initializing libiomp5.dylib, but found libomp.dylib already initialized." (OpenMP library conflict due to conda's MKL)
    for LIBOMP_ALIAS in libgomp.dylib libiomp5.dylib libomp.dylib; do sudo ln -sf "$(brew --cellar libomp)"/*/lib/libomp.dylib $CONDA_PREFIX/lib/$LIBOMP_ALIAS || exit -1; done
fi

mkdir $BUILD_DIRECTORY/build && cd $BUILD_DIRECTORY/build
cmake "${CMAKE_OPTS[@]}" ..
make _lightgbm -j4 || exit -1

cd $BUILD_DIRECTORY/python-package && python setup.py install --precompile --user || exit -1
cd $BUILD_DIRECTORY/tests
python 2399.py || exit -1  # run test