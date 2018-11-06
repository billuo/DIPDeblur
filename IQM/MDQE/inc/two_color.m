function [center1, center2, err] = two_color(img)

assert(size(img, 3) == 3);
r = img(:, :, 1);
g = img(:, :, 2);
b = img(:, :, 3);

patch_size = [5, 5];
margin = floor(patch_size / 2);

r_col = im2col(r, patch_size);
g_col = im2col(g, patch_size);
b_col = im2col(b, patch_size);

r = r(margin(1) + 1 : end - margin(1), margin(2) + 1 : end - margin(2));
g = g(margin(1) + 1 : end - margin(1), margin(2) + 1 : end - margin(2));
b = b(margin(1) + 1 : end - margin(1), margin(2) + 1 : end - margin(2));
img = img(margin(1) + 1 : end - margin(1), margin(2) + 1 : end - margin(2), :);

[r_centers, g_centers, b_centers] = ...
        init_centers(r_col, g_col, b_col, patch_size);

diff = cell(2, 1);
max_iter = 10;
for iter = 1 : max_iter
    for k = 1 : 2
        diff{k} = bsxfun(@minus, r_col, r_centers{k}) .^ 2 + ...
                  bsxfun(@minus, g_col, g_centers{k}) .^ 2 + ...
                  bsxfun(@minus, b_col, b_centers{k}) .^ 2;
    end
    
    sum(vec(min(diff{1}, diff{2})));
    map = double(diff{1} <= diff{2});
    
    for k = 1 : 2
        map_sum = sum(map);
        map_sum(map_sum < 1e-10) = 1e+10;
        
        norm_coef = 1.0 ./ map_sum;
        r_centers{k} = sum(r_col .* map) .* norm_coef;
        g_centers{k} = sum(g_col .* map) .* norm_coef;
        b_centers{k} = sum(b_col .* map) .* norm_coef;
        
        map = 1.0 - map;
    end
    
    diff1 = (r_centers{1} - r(:)') .^ 2 + ...
            (g_centers{1} - g(:)') .^ 2 + ...
            (b_centers{1} - b(:)') .^ 2;
    diff2 = (r_centers{2} - r(:)') .^ 2 + ...
            (g_centers{2} - g(:)') .^ 2 + ...
            (b_centers{2} - b(:)') .^ 2;
    map = (diff1 > diff2);
    
    tmp = r_centers{1}(map);
    r_centers{1}(map) = r_centers{2}(map);
    r_centers{2}(map) = tmp;

    tmp = g_centers{1}(map);
    g_centers{1}(map) = g_centers{2}(map);
    g_centers{2}(map) = tmp;
    
    tmp = b_centers{1}(map);
    b_centers{1}(map) = b_centers{2}(map);
    b_centers{2}(map) = tmp;
end

center1 = zeros(size(img));
center1(:, :, 1) = reshape(r_centers{1}, size(r));
center1(:, :, 2) = reshape(g_centers{1}, size(g));
center1(:, :, 3) = reshape(b_centers{1}, size(b));
    
center2 = zeros(size(img));
center2(:, :, 1) = reshape(r_centers{2}, size(r));
center2(:, :, 2) = reshape(g_centers{2}, size(g));
center2(:, :, 3) = reshape(b_centers{2}, size(b));

diff = center2 - center1;
len = sqrt(sum(diff .^ 2, 3));
dir = bsxfun(@rdivide, diff, len + 1e-12);

diff = img - center1;
proj = sum(diff .* dir, 3);
dist = diff - bsxfun(@times, dir, proj);
err = sqrt(sum(dist .^ 2, 3));
    
end


function [rc, gc, bc] = init_centers(r_col, g_col, b_col, patch_size)

idx = randi(prod(patch_size), [1, size(r_col, 2)]);
rc = cell(2, 1);
gc = cell(2, 1);
bc = cell(2, 1);

c_idx = sub2ind(size(r_col), idx, 1 : numel(idx));
    
rc{1} = r_col(c_idx);
gc{1} = g_col(c_idx);
bc{1} = b_col(c_idx);

diff = bsxfun(@minus, r_col, rc{1}) .^ 2 + ...
       bsxfun(@minus, g_col, gc{1}) .^ 2 + ...
       bsxfun(@minus, b_col, bc{1}) .^ 2;

nonzero_num = sum(int32(diff > 1e-12));
[~, s_idx] = sort(diff, 1, 'descend');
idx = s_idx(sub2ind(size(s_idx), max(ceil(nonzero_num * 0.5), 1), ...
                    1 : numel(nonzero_num)));
c_idx = sub2ind(size(r_col), idx, 1 : numel(idx));
    
rc{2} = r_col(c_idx);
gc{2} = g_col(c_idx);
bc{2} = b_col(c_idx);

end
