# Summary of Assessment 
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

### GoPro dataset:

| Model | PSNR | WSNR | SSIM | MSSSIM | IFC | NQM | UIQI | VIF | BIQI | BLIINDS2 | BRISQUE | CORNIA | DIIVINE | NIQE | SSEQ | MDQE |
| -------- | ---- | ---- | ---- | ------ | --- | --- | ---- | --- | ---- | -------- | ------- | ------ | ------- | ---- | ---- | ---- |
| SRN | 27.51 | 24.96 | 0.85 | 0.90 | 3.13 | 23.18 | 0.70 | 0.56 | 36.33 | 39.10 | 116.30 | 124.30 | 52.87 | 19.99 | 48.45 | -10.52 |
| DeepDeblur | 26.62 | 23.85 | 0.84 | 0.90 | 2.82 | 20.70 | 0.66 | 0.57 | 33.60 | 38.39 | 116.33 | 124.24 | 52.30 | 19.95 | 47.99 | -10.12 |
| DeblurGAN  | 25.33 | 24.33 | 0.78 | 0.85   | 2.12 | 22.07 | 0.58 | 0.68 | 37.41 | 30.85    | 114.17  | 122.74 | 47.45   | 19.56 | 32.62 | -10.30 |

### Lai *et al.*

1. DeepDeblur:

2. SRN:

3. DeblurGAN:

| metrics | real | uniform | non-uniform |
| ------- | ---- | ------- | ----------- |
|PSNR |-  |15.7737  |16.6705     |
|WSNR |-  |11.4393  |12.6790     |
|SSIM |-  |0.4316  |0.4938     |
|MS-SSIM |-  |0.4463  |0.6195     |
|IFC |-  |0.1889  |0.4441     |
|NQM |-  |5.5210  |6.9118     |
|UIQI |-  |0.0805  |0.1874     |
|VIF |-  |0.0692  |0.2198     |
|BIQI     |3.7364  |55.1539  |35.6432     |
|BLIINDS2 |38.9100  |36.0000  |30.5950     |
|BRISQUE |115.9636  |117.7755  |112.9779     |
|CORNIA |123.8458  |125.8382  |123.3886     |
|DIIVINE |43.4891  |48.9693  |47.8522     |
|NIQE |19.6641  |19.3546  |19.1597     |
|SSEQ |39.0832  |32.5474  |28.2454     |

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

Orignal codes can be got at https://github.com/KupynOrest/DeblurGAN You can set up your environment accourding to their guidlines. 

The deblurred images for assessments: 

*  GoPro dataset: https://jbox.sjtu.edu.cn/l/B1xGcT

*  Lai's dataset: https://jbox.sjtu.edu.cn/l/3Jv9Sl
