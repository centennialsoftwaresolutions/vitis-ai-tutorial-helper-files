#!/bin/bash
git clone https://github.com/AlexeyAB/darknet
git clone https://github.com/Tianxiaomo/pytorch-YOLOv4.git

# overwrite buggy file
cp ./utils.py pytorch-YOLOv4/tool/utils.py

if [[ $1 == "cpu" ]]; then
    cp ./darknet-helpers/Makefile.cpu ./darknet/Makefile -v
else
    cp ./darknet-helpers/Makefile.gpu ./darknet/Makefile -v
fi

mkdir -pv ./darknet/cfg/yolov4_leaky/snapshots

#git clone https://github.com/david8862/keras-YOLOv3-model-set
conda create -n yolov4 pip python=3.8
conda activate yolov4
cd ~/opencv-4.4.0/modules/python/package
python3 setup.py install
cd -
pip3 install pycocotools python-rapidjson numpy tqdm onnx onnxruntime
pip3 install protobuf==3.20.0
