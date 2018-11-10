# IQM - Image Quality Metrics Matlab toolbox

## Supported algorithms
    algorithm                               name
    -----------------------------------     -----------
    mean-squared error                      'MSE'
    signal-to-noise ratio                   'SNR'
    peak signal-to-noise ratio              'PSNR'
    weighted signal-to-noise ratio          'WSNR'
    structural similarity index             'SSIM'
    multiscale SSIM index                   'MSSSIM'
    visual information fidelity             'VIF'
    image fidelity criterion                'IFC'
    noise quality measure                   'NQM'
    universal quality index                 'UIQI'
    naturalness image quality evaluator     'NIQE'
    motion deblurring quality evaluator     'MDQE'(*)
    TODO                                    'BLIINDS2'
    TODO                                    'BRISQUE'
    TODO                                    'DIIVINE'
    TODO                                    'SSEQ'
    TODO                                    'BIQI'
    TODO                                    'CORNIA'

\*  A custom acronym for the metric approved in:
    Y. Liu, J. Wang, S. Cho, A. Finkelstein, and S. Rusinkiewicz.
    A no-reference metric for evaluating the quality of motion deblurring.
    ACM TOG (Proc. SIGGRAPH Asia), 32(6):175, 2013.

## Files
All supported image quality metrics have their own self-contained directory,
each with the same name as their acronyms.  
Contained in 'Utilities' are libsvm (version 3.1), dwt2d and matlabPyrTools, as needed by some metrics.  
The .m prefixed with iqm in the same directory as this README.txt is the only interface exposed.  

**NOTE:** *SSEQ requires a newer version of libsvm (MATLAB interface).
Thus some precompiled .mex are present in directory './SSEQ'.
For now, the extra libsvm is of version 3.27.*

## Usage
* Everytime before use you need to run 'iqm\_configure.m'.
    * After configurating it automatically runs a simple test.
* Once properly setup, call iqm() to evaluate any supported metrics.

*Refer to source files for in-source documentation and implementation details.*

Example:
``` matlab
>>iqm_configure                     % MUST run it first! And if it's the first time,
                                    % cd into its directory before running.
>>iqm('PSNR', img, img_ref)         % Evaluates PSNR
>>iqm('NIQE', img)                  % Evaluates NIQE
>>iqm('MDQE', blurred, deblurred)   % Evaluates MDQE
```

**Due to size limit, CORNIA/LIVE_soft_svm_model.mat is ignored in repository.
It should be later uploaded elsewhere for downloading.**
