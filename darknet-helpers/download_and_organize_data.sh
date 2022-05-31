#!/bin/bash
sudo mkdir -pv /data2/datasets/coco/coco2017/{images,labels}
sudo chown $USER:$GROUP -R /data2/
wget http://images.cocodataset.org/zips/train2017.zip
wget http://images.cocodataset.org/zips/val2017.zip
wget http://images.cocodataset.org/annotations/annotations_trainval2017.zip
echo "Unziping training images"
unzip -q train2017.zip -d /data2/datasets/coco/coco2017/images/
echo "Unziping evaluation images"
unzip -q val2017.zip -d /data2/datasets/coco/coco2017/images/
echo "Unziping annotation data"
unzip -q annotations_trainval2017.zip -d /data2/datasets/coco/coco2017/
