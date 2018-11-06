IQM - Image Quality Metrics Matlab toolbox

Everytime before use you need to run 'iqm_configure.m'.
After configurating it automatically runs a simple test.

Once properly setup, call iqm() to evaluate any supported metrics.
Refer to source files for in-source documentation and implementation details.

e.g. (in matlab console)
>>iqm_configure                     % MUST run it first!
>>iqm('PSNR', img, img_ref)         % Evaluates PSNR
>>iqm('NIQE', img)                  % Evaluates NIQE
>>iqm('MDQE', blurred, deblurred)   % Evaluates MDQE (Liu et al.)


        THIS IS A WORK IN PROGRESS!!!
        THIS IS A WORK IN PROGRESS!!!
        THIS IS A WORK IN PROGRESS!!!
