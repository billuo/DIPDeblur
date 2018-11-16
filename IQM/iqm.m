function [metric] = iqm(name, img, varargin)
% IQM Evaluate a specific image quality metric on given image(s).
%   _name_:       Metric name, char/string array.
%   _img_:        Input image, can be of any depth and dimensions.
%   _img_ref_:    Reference image (optional), must be of the same dimension as _img_.
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
            error('Metric ''%s'' does not exist.\nSupported metrics:\n%s', name, string(join(keys(iqm_function_handles))));
        else
            rethrow(ME);
        end
    end
    %% Parse and validate arguments
    if is_full_reference(name)
        assert(~isempty(varargin), 'metric ''%s'' expects a reference image, but none was given.', name);
        if nargin > 3
            warning('%d Excessive argument(s)', nargin - 3);
        end
        img_ref = varargin{1};
    elseif ~isempty(varargin)
        % warn('Excessive arguments(s)'); % XXX ok...?
    end
    %% Preprocess the image: NOTE that preprocessing can load a image given a file name
    img = iqm_preprocess(name, img);
    if is_full_reference(name)
       img_ref = iqm_preprocess(name, img_ref);
    end
    %% Check image size
    assert(all(size(img) ~= 0), 'At least one dimention of the input image is zero.');
    if is_full_reference(name)
        assert(all(size(img_ref) ~= 0), 'At least one dimention of the reference image is zero.');
        assert(all(size(img) == size(img_ref)), 'Sizes of input image and reference image disagree.');
    end
    %% Invoke the function handle
    if is_full_reference(name)
        metric = F(img, img_ref);
    else
        metric = F(img);
    end
end

function yes = is_full_reference(name)
    yes = any(string(name) == ["MSE", "SNR", "PSNR", "WSNR", "SSIM", "MSSSIM", ...
        "VIF", "IFC", "NQM", "UIQI", "MDQE"]);
end

