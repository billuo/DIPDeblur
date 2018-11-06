function [metric] = iqm(name, img, varargin)
% IQM Evaluate a specific image quality metric on given image(s).
% _name_:       Metric name, char/string array.
% _img_:        Input image, can be of any depth and dimensions.
% _img_ref_:    Reference image (optional), must be of the same dimension as _img_.
%
%   algorithm                       name
%   ---------------------------     ----------------
%   mean-squared error              'MSE'
%   peak signal-to-noise ratio      'PSNR'
%   structural similarity index     'SSIM'
%   multiscale SSIM index           'MSSIM'
%   visual signal-to-noise ratio    'VSNR'
%   visual information fidelity     'VIF'
%   pixel-based VIF                 'VIFP'
%   universal quality index         'UQI'
%   image fidelity criterion        'IFC'
%   noise quality measure           'NQM'
%   weighted signal-to-noise ratio  'WSNR'
%   signal-to-noise ratio           'SNR'
    %% Check image size
    if find(size(img) == 0)
        error('At least one dimention of the input image is zero.');
    end
    if nargin > 2
        img_ref = varargin{1};
        if find(size(img_ref) == 0)
            error('At least one dimention of the reference image is zero.');
        end
        if find(size(img) ~= size(img_ref))
            error('Sizes of input image and reference image disagree.');
        end
    end
    %% Identify the metric algorithm
    if isstring(name)
        name = char(name);
    end
    name = upper(name);
    global iqm_function_handles;
    try
        F = iqm_function_handles(name);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:Containers:Map:NoKey')
            error('Metric ''%s'' does not exist.\nSupported metrics:\n%s', join(keys(iqm_function_handles)));
        else
            rethrow(ME);
        end
    end
    if is_full_reference(name)
        metric = F(iqm_preprocess(name, img), iqm_preprocess(name, varargin{1}));
    else
        metric = F(iqm_preprocess(name, img));
    end
end

function yes = is_full_reference(name)
    yes = find(string(name) == ["MSE", "SNR", "PSNR", "WSNR", "VSNR", "SSIM", "MSSSIM", ...
        "VIF", "VIFP", "IFC", "NQM", "UIQI", "MDQE"]);
end

