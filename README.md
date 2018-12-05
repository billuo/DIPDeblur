# DIP-deblur
For group project of Digital Image Processing on blind image deblurring.

## Directories

| directory | description |
| :-------: |-------------|
| IQM | Image Quality Metric Matlab toolbox |
| etc | Codes and results of evaluated models |

## IQM

Supports easy image quality evaluation with 16+ flavours, namely:
1. Full-reference metrics
    * MSE
    * SNR
    * PSNR
    * WSNR
    * SSIM
    * MSSSIM
    * VIF
    * IFC
    * NQM
    * UIQI
2. No-reference metrics 
    * NIQE
    * Liu et al. (MDQE)
    * BLIINDS2
    * BRISQUE
    * DIIVINE
    * SSEQ
    * BIQI
    * CORNIA

For its usage, refer to IQM/README.md. Some in-source documentation found in 'IQM/iqm\*.m'.

Note the list of quality metrics supported here is the superset of that compared in:
*Wei-Sheng Lai, Jia-Bin Huang, Zhe Hu, Narendra Ahuja, and Ming-Hsuan Yang, A Comparative Study for Single Image Blind Deblurring, IEEE Conference on Computer Vision and Pattern Recognition, 2016.*
