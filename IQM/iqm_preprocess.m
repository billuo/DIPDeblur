function preprocessed_image = iqm_preprocess(metric_name, input_image)
% IQM_PREPROCESS Preprocess an image for a specific metric, return the processed image.
%   Invariant after preprocessing:
%   Image will be an array of double. (Even if given only an image file name)
%   Image will be padded in height and width as needed.
%   Image depth is converted to 1 (gray scale) if needed.
    %% Load image if it's a file name rather than a Matlab image
    if ischar(input_image) || isstring(input_image)
        try
            image = imread(input_image);
        catch ME
            if strcmp(ME.identifier, 'MATLAB:imagesci:imread:fileDoesNotExist')
                error('''%s'' is neither a Matlab image or the name of an existing image file.', input_image);
            else
                rethrow(ME);
            end
        end
    else
        % Don't modify the original image: clone one
        image = zeros(size(input_image), class(input_image));
        image(:) = input_image(:);
    end
    %% Cast to double if not already
    if ~isa(image, 'double')
        image = im2double(image); % im2double automatically rescale to [0, 1]
    end
    %% Convert depth to 1 if necessary.
    [H, W, D] = size(image);
    if not(multichannel(metric_name)) && (D ~= 1)
        if D == 3
            image = rgb2gray(image); % Assume it to be sRGB.
        else
            error('Color space of the input image could not be converted. (Depth = %d)', D);
        end
    end
    %% Add padding if necessary
    if  need_padding(metric_name)
        %% Calculate new height and width
        if string(metric_name) == "NIQE"
            padding_size = 96;
        else
            padding_size = 32;
        end
        H_minimum = 128;
        W_minimum = 128;
        H_needed = max(H_minimum, padding_size * ceil(H / padding_size));
        W_needed = max(W_minimum, padding_size * ceil(W / padding_size));
        if (H ~= H_needed) || (W ~= W_needed)
            padded_image = zeros(H_needed, W_needed);
            %% Calculate size of a symmetric padding
            p_top = ceil((H_needed - H) / 2);
            p_bottom = H_needed - H - p_top;
            p_left = ceil((W_needed - W) / 2);
            p_right = W_needed - W - p_left;
            %% Wrap edge pixels
            padded_image(p_top + (1:H), 1:p_left) = image(1:H, 1 + min(W - 1, p_left:-1:1)); % left edge
            padded_image(p_top + (1:H), p_left + W + 1:end) = image(1:H, W - min(W - 1, 1:p_right)); % right edge
            padded_image(1:p_top, p_left + (1:W)) = image(1 + min(H - 1, p_top:-1:1), 1:W); % up edge
            padded_image(p_top + H + 1:end, p_left + (1:W)) = image(H - min(H - 1, 1:p_bottom), 1:W); % bottom edge
            %% Copy corner pixels
            padded_image(1:p_top,1:p_left) = image(min(H, 2), min(W, 2));
            padded_image(p_top + H + 1:end,1:p_left) = image(max(H - 1, 1), min(W, 2));
            padded_image(1:p_top,p_left + W + 1:end) = image(min(H, 2), max(W - 1, 1));
            padded_image(p_top + H + 1:end,p_left + W + 1:end) = image(max(H - 1, 1), max(W - 1, 1));
            %% Copy the main part of the image
            padded_image(p_top + (1:H),p_left + (1:W)) = image;
            image = padded_image;
        end
    end
    preprocessed_image = image;
end

function yes = multichannel(metric_name)
% Return 0 if metric_name can only process monocolor image, 1 otherwise.
    yes = any(string(metric_name) == ["MSE", "SNR", "PSNR", "MDQE"]);
end

function yes = need_padding(metric_name)
% Return 1 if metric_name must operate on image of specific size, 0 otherwise.
    yes = any(string(metric_name) == ["VIF", "IFC", "VSNR"]);
end
