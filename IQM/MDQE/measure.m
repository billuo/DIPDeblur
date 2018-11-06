function [score, details] = measure(deblurred, blurred)
% Evaluate the quality of motion deblurring.
%
% by Yiming Liu (yimingl@cs.princeton.edu)
%
% Input arguments:
%  * deblurred: the deblurring result. It should be a three-channel RGB image.
%    The pixel value should be within [0.0, 1.0].
%  * blurred: the blurry image (the input of the deblurring algorithm). It
%    should also be a three-channel RGB image. The pixel value should be within
%    [0.0, 1.0].
%
% Output:
%  * score: a numerical value representing the quality of the deblurring
%    result. Larger values mean higher quality.
%  * details: a struct that contains the feature values.

features = struct();
features.sparsity = sparsity(deblurred);
features.smallgrad = smallgrad(deblurred);
features.metric_q = metric_q(deblurred);

denoised = denoise(deblurred);
features.auto_corr = auto_corr(denoised);
features.norm_sps = norm_sparsity(denoised);
features.cpbd = cpbd(denoised);

features.pyr_ring = pyr_ring(denoised, blurred);
features.saturation = saturation(deblurred);

score = features.sparsity   * -8.70515   + ...
        features.smallgrad  * -62.23820  + ...
        features.metric_q   * -0.04109   + ...
        features.auto_corr  * -0.82738   + ...
        features.norm_sps   * -13.90913  + ...
        features.cpbd       * -2.20373   + ...
        features.pyr_ring   * -149.19139 + ...
        features.saturation * -6.62421;

if nargout >= 2
    details = features;
end

end


function result = sparsity(img)

d = cell(1, 3);
for c = 1 : 3
    [dx, dy] = gradient(img(:, :, c));
    d{c} = vec(sqrt(dx .^ 2 + dy .^ 2));
end
result = 0;
for c = 1 : 3
    result = result + mean_norm(d{c}, 0.66);
end

end

function result = smallgrad(img)

d = zeros(size(img(:, :, 1)));
for c = 1 : 3
    [dx, dy] = gradient(img(:, :, c));
    d = d + sqrt(dx .^ 2 + dy .^ 2);
end
d = d  / 3;

sorted = sort(d(:));
noises = [];
n = max(floor(numel(sorted) * 0.3), 10);
result = my_sd(sorted(1 : n), 0.1);

end


function result = metric_q(img)

PATCH_SIZE = 8;
img = rgb2gray(img) * 255;
aniso_set = AnisoSetEst(img, PATCH_SIZE);
result = -MetricQ(img, PATCH_SIZE, aniso_set);

end


function result = auto_corr(img)

img = rgb2gray(img);

MARGIN = 50;
ncc_orig = compute_ncc(img, img, MARGIN);

sizes = size(ncc_orig);
assert(sizes(1) == sizes(2));
assert(mod(sizes(1), 2) == 1);
radius = floor(sizes(1) / 2);
[y_dists, x_dists] = ndgrid(0 : sizes(1) - 1, 0 : sizes(2) - 1);
dists = sqrt((y_dists - radius) .^ 2 + (x_dists - radius) .^ 2);

ncc = abs(ncc_orig);
max_m = zeros(1, 1 + radius);
for r = 0 : radius
    w = abs(dists - r);
    w = min(w, 1);
    w = (1 - w);
    max_m(r + 1)  = max(vec(ncc(w > 0)));
end

max_m(1)  = 0;
result = sum(max_m);

end

function ncc = compute_ncc(img, ref, img_margin)

assert(size(img, 3) == 1);
template = ref(img_margin + 1 : end - img_margin, img_margin + 1 : end - img_margin, :);
ncc = ones(img_margin * 2 + 1, img_margin * 2 + 1) * 100;
ncc_abs = ones(img_margin * 2 + 1, img_margin * 2 + 1) * 100;

img_mask = mask_lines(img);
ref_mask = mask_lines(ref);
t_mask = ref_mask(img_margin + 1 : end - img_margin, img_margin + 1 : end - img_margin);

[ dx,  dy] = gradient(img);
[tdx, tdy] = gradient(template);

dx(img_mask) = false;
dy(img_mask) = false;
tdx(t_mask)  = false;
tdy(t_mask)  = false;

ncc_dx = xcorr2_fft(tdx, dx);
ncc_dy = xcorr2_fft(tdy, dy);

ncc_dx = ncc_dx(size(tdx, 1) : end, size(tdx, 2) : end);
ncc_dy = ncc_dy(size(tdy, 1) : end, size(tdy, 2) : end);

ncc_dx = ncc_dx(1 : img_margin * 2 + 1, 1 : img_margin * 2 + 1);
ncc_dy = ncc_dy(1 : img_margin * 2 + 1, 1 : img_margin * 2 + 1);

ncc_dx = ncc_dx / ncc_dx(img_margin + 1, img_margin + 1);
ncc_dy = ncc_dy / ncc_dy(img_margin + 1, img_margin + 1);

ncc_dx_abs = abs(ncc_dx);
ncc_dy_abs = abs(ncc_dy);

mask = ncc_dx_abs < ncc_abs;
ncc(mask) = ncc_dx(mask);
ncc_abs(mask) = ncc_dx_abs(mask);

mask = ncc_dy_abs < ncc_abs;
ncc(mask) = ncc_dy(mask);
ncc_abs(mask) = ncc_dy_abs(mask);

end


function result = norm_sparsity(img)

[dx, dy] = gradient(rgb2gray(img));
d = sqrt(dx .^ 2 + dy .^ 2);
result = mean_norm(d, 1.0) / mean_norm(d, 2.0);

end


function result = cpbd(img)

img = rgb2gray(uint8(img * 255));
result = -CPBD_compute(img);

end


function result = pyr_ring(img, blurred)

[img, blurred] = align(img, blurred, true);
[height, width, color_count] = size(img);

result = 0.0;
sizes = [];
j = 0;
while true
    coef = 0.5 ^ j;
    cur_height = round(height * coef);
    cur_width = round(width * coef);
    if min(cur_height, cur_width) < 16
        break;
    end
    sizes = cat(1, sizes, [j, cur_width, cur_height]);

    cur_img = imresize(img, [cur_height, cur_width], 'bilinear');
    cur_blurred = imresize(blurred, [cur_height, cur_width], 'bilinear');

    diff = grad_ring(cur_img, cur_blurred);
    if j > 0
        result = result + mean(diff(:));
    end

    j = j + 1;
end

end


function result = saturation(img)

max_values = max(img, [], 3);
mask = (max_values <= 10.0 / 255.0);
result_low = sum(double(mask(:))) / prod(size(max_values));

min_values = min(img, [], 3);
mask = (min_values >= 1.0 - (10.0 / 255.0));
result_high = sum(double(mask(:))) / prod(size(min_values));

result = result_low + result_high;

end


function sd = my_sd(x, p)

avg = mean(x(:));
sd  = mean(vec(abs(x - avg)) .^ p) .^ (1.0 / p);

end

