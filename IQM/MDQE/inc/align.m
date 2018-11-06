function [image, ref] = align(image, ref, return_images)

% if return_images == true, then
%    [image, ref] = align(image, ref, true);
% else
%    [dx,    dy ] = align(image, ref, false);

if ~exist('return_images', 'var')
    return_images = false;
end

margin = 75;

template = image(margin + 1 : end - margin, margin + 1 : end - margin, :);
template_size = size(template);
template_size = template_size + mod(size(template), 2) - 1;
template_size = template_size(1 : 2);
template = template(1 : template_size(1), 1: template_size(2), :);

ref_size = size(ref);
ncc_size = ref_size(1 : 2) + template_size - 1;
ncc = zeros(ncc_size);
for k = 1 : 3
    ncc = ncc + normxcorr2(template(:, :, k), ref(:, :, k));
end
%ncc = normxcorr2(rgb2gray(template), rgb2gray(ref));

ncc_margin = floor(template_size / 2);
ncc = ncc(ncc_margin(1) + 1 : end - ncc_margin(1), ...
          ncc_margin(2) + 1 : end - ncc_margin(2));

[~, max_idx] = max(ncc(:));
[dy, dx] = ind2sub(size(ncc), max_idx);
dy = dy - 1 - floor(template_size(1) / 2) - margin;
dx = dx - 1 - floor(template_size(2) / 2) - margin;

if return_images
    if dy < 0
        height = min(size(image, 1) + dy, size(ref, 1));
        image = image(1 - dy : height - dy, :, :);
        ref = ref(1 : height, :, :);
    else
        height = min(size(image, 1), size(ref, 1) - dy);
        image = image(1 : height, :, :);
        ref = ref(1 + dy : height + dy, :, :);
    end
    if dx < 0
        width = min(size(image, 2) + dx, size(ref, 2));
        image = image(:, 1 - dx : width - dx, :);
        ref = ref(:, 1 : width, :);
    else
        width = min(size(image, 2), size(ref, 2) - dx);
        image = image(:, 1 : width, :);
        ref = ref(:, 1 + dx : width + dx, :);
    end
else
    image = dx;
    ref   = dy;
end

end
