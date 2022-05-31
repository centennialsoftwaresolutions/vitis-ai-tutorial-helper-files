#!/bin/bash

# Copyright 2021 Xilinx Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export ONNXRT_VAI_HOME=$(pwd)
export ONNXRT_HOME="${ONNXRT_VAI_HOME}"/onnxruntime
export PYXIR_HOME="${ONNXRT_VAI_HOME}"/pyxir

python3 -m ensurepip

if [ -d "${ONNXRT_HOME}" ]; then
  rm -rf ${ONNXRT_HOME}
fi
if [ -d "${PYXIR_HOME}" ]; then
  rm -rf ${PYXIR_HOME}
fi

# CREATE SWAP SPACE
if [ ! -f "/swapfile" ]; then
  fallocate -l 8G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile swap swap defaults 0 0" > /etc/fstab
else
  echo "Couldn't allocate swap space as /swapfile already exists"
fi

# INSTALL DEPENDENCIES
if ! command -v h5cc &> /dev/null; then
  cd /tmp && \
    wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.7/src/hdf5-1.10.7.tar.gz && \
    tar -zxvf hdf5-1.10.7.tar.gz && \
    cd hdf5-1.10.7 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && rm -rf hdf5-1.10.7*
fi

cd ${ONNXRT_VAI_HOME}

pip3 install h5py==2.10.0 pillow wheel onnx==1.9 protobuf==3.20.1

# DOWNLOAD PYXIR AND ONNX RUNTIME
git clone --recursive --branch v0.2.0 --single-branch https://github.com/Xilinx/pyxir.git "${PYXIR_HOME}"
git clone --recursive --branch v1.9.2 --single-branch https://github.com/microsoft/onnxruntime.git "${ONNXRT_HOME}"

# line 99 of the file below causes compilation issues - so we're just removing it
sed -i '99d' /home/root/onnxruntime/onnxruntime/python/onnxruntime_pybind_state_common.cc

# BUILD PYXIR FOR EDGE
cd "${PYXIR_HOME}"
sudo python3 setup.py install --use_vai_rt_dpuczdx8g --use_dpuczdx8g_vart

# BUILD ONNX RUNTIME
cd "${ONNXRT_HOME}"
./build.sh --use_openmp --config RelWithDebInfo --enable_pybind --build_wheel --use_vitisai --parallel --update --build --build_shared_lib
pip3 install build/Linux/RelWithDebInfo/dist/*.whl
