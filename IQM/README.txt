IQM - Image Quality Metrics Matlab toolbox

Everytime before use you need to run 'iqm_configure.m'.
After configurating it automatically runs a simple test.

    NOTE: Currently during the test some won't even compute while some compute obviously wrong result.
    TODO: Manually test against the example given in the subfolder of each metric and fix the wrong ones.

Once properly setup, call iqm() to evaluate any supported metrics.
Refer to source files for in-source documentation and implementation details.

Supported algorithms:
    algorithm                               name
    ---------------------------             ----------------
    mean-squared error                      'MSE'
    signal-to-noise ratio                   'SNR'
    peak signal-to-noise ratio              'PSNR'
    weighted signal-to-noise ratio          'WSNR'
    structural similarity index             'SSIM'
    multiscale SSIM index                   'MSSIM'
    visual information fidelity             'VIF'
    image fidelity criterion                'IFC'
    noise quality measure                   'NQM'
    universal quality index                 'UQI'
    naturalness image quality evaluator     'NIQE'
    motion deblurring quality evaluator     'MDQE'(*)
    TODO                                    'BLIINDS'
    TODO                                    'BRISQUE'
    TODO                                    'DIIVINE'
    TODO                                    'SSEQ'
    TODO                                    'BIQI'
    TODO                                    'CORNIA'

* A custom acronym for the metric approved in:
    Y. Liu, J. Wang, S. Cho, A. Finkelstein, and S. Rusinkiewicz.
    A no-reference metric for evaluating the quality of motion deblurring.
    ACM TOG (Proc. SIGGRAPH Asia), 32(6):175, 2013.

e.g. (in matlab console)
>>iqm_configure                     % MUST run it first!
>>iqm('PSNR', img, img_ref)         % Evaluates PSNR
>>iqm('NIQE', img)                  % Evaluates NIQE
>>iqm('MDQE', blurred, deblurred)   % Evaluates MDQE

Due to size limit, CORNIA/LIVE_soft_svm_model.mat is ignored in repository.
It will be later uploaded elsewhere for downloading.
