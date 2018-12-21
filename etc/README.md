# etc
This directory contains the code for models we evaluated together with the evaluation result,
each in a self contained subdirectory.  
They are released by authors of the corresponding essays!

## Directories

| directory | contents |
| --------- | -------- |
| DeepDeblur\_release | Torch implementation of model in *Deep Multi-Scale Convolutional Neural Network for Dynamic Scene Deblurring* |
| SRN-Deblur-master | *Scale-recurrent Network for Deep Image Deblurring* |

## Evaluation Result Overview

A brief overview of these models evaluated by a variety of image quality metrics (average value):

| Model | PSNR | WSNR | SSIM | MSSSIM | IFC | NQM | UIQI | VIF | BIQI | BLIINDS2 | BRISQUE | CORNIA | DIIVINE | NIQE | SSEQ | MDQE |
| -------- | ---- | ---- | ---- | ------ | --- | --- | ---- | --- | ---- | -------- | ------- | ------ | ------- | ---- | ---- | ---- |
| SRN | 27.51 | 24.96 | 0.85 | 0.90 | 3.13 | 23.18 | 0.70 | 0.56 | 36.33 | 39.10 | 116.30 | 124.30 | 52.87 | 19.99 | 48.45 | -10.52 |
| DeepDeblur | 26.62 | 23.85 | 0.84 | 0.90 | 2.82 | 20.70 | 0.66 | 0.57 | 33.60 | 38.39 | 116.33 | 124.24 | 52.30 | 19.95 | 47.99 | -10.12 |
| DeblurGAN  | 25.33 | 24.33 | 0.78 | 0.85   | 2.12 | 22.07 | 0.58 | 0.68 | 37.41 | 30.85    | 114.17  | 122.74 | 47.45   | 19.56 | 32.62 | -10.30 |

## DeepDeblur\_release
Evaluation result is computed by *./compute\_metrics.mat*
and stored in *./dataset/GOPRO\_Large-test.zip*,
using the trained model given in *./README.md*.  
Read **./README.md** for detailed description on how to run the code.  
The deblurred images used in computation can be downloaded at:  
https://pan.baidu.com/s/1d96gG--1B7a0lQg2tdBdlQ

## SRN

Evaluation result is stored in *./dataset/SRN\_metrics\_result.zip*,
using the trained model given in *./README.md*.  
Read **./README.md** for detailed description on how to run the code.  
The deblurred images used in computation can be downloaded at:  
https://pan.baidu.com/s/18hL6yPL1zicIMRlBuedpAw

## DebulrGAN

Orignal codes can be got at https://github.com/KupynOrest/DeblurGAN
Detailed evaluation results & deblurred images will be uploaded later...
