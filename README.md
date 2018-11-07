# DIP-deblur
For group project of Digital Image Processing on blind image deblurring.

## Directories

| directory | description |
| :-------: |-------------|
| IQM | Image Quality Metric Matlab toolbox|

## IQM

Supports easy image quality evaluation with 16+ flavours, namely:
1. Full-reference metrics
    * MSE
    * SNR
    * PSNR
    * WSNR
    * SSIM
    * MSSSIM
    * IFC
    * NQM
    * UIQI
    * VIF
2. No-reference metrics 
    * BIQI
    * BLIINDS2
    * BRISQUE
    * CORNIA
    * DIIVINE
    * NIQE
    * SSEQ
    * Liu et al.

**TODO: Only a few of them works! Fix them (refer to IQM/README.txt for details)**

For its usage, refer to in-source documentation in 'IQM/iqm\*.m'.

Note the list of quality metrics supported here is the superset of that compared in:

*Wei-Sheng Lai, Jia-Bin Huang, Zhe Hu, Narendra Ahuja, and Ming-Hsuan Yang, A Comparative Study for Single Image Blind Deblurring, IEEE Conference on Computer Vision and Pattern Recognition, 2016.*
