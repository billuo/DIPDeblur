function result = grad_ring(latent, ref)

assert(isa(latent, 'double'));
assert(isa(ref, 'double'));
assert(size(ref, 3) == size(latent, 3));

g = make_gaussian(15);
assert(size(g, 1) == 1);

result = zeros(size(latent));
for c = 1 : size(ref, 3)
    [tdx, tdy] = gradient(ref(:, :, c));
    [ldx, ldy] = gradient(latent(:, :, c));

    rx = abs(ldx) - conv2(abs(tdx), g, 'same');
    ry = abs(ldy) - conv2(abs(tdy), g', 'same');
    rx = max(rx, 0);
    ry = max(ry, 0);

    result(:, :, c) = sqrt(rx .^ 2 + ry .^ 2);
end

gx = zeros(size(ref));
gy = zeros(size(ref));
for c = 1 : size(ref, 3)
    [gx(:, :, c), gy(:, :, c)] = gradient(ref(:, :, c));
end
g = sqrt(gx .^ 2 + gy .^ 2);

%g = conv2(g(:, :, 1), ones(5, 5) / 25.0, 'same') + ...
%    conv2(g(:, :, 2), ones(5, 5) / 25.0, 'same') + ...
%    conv2(g(:, :, 3), ones(5, 5) / 25.0, 'same');
%result = bsxfun(@rdivide, result, g);

filter_width = floor(max(max(size(latent)) / 200, 1));
emask = double(g > 0.03);
emask = (imfilter(emask, ones(filter_width), 'same') > 0);
result(emask) = 0.0;

end


function g = make_gaussian(len)

r = floor(len / 2);
assert(r + r + 1 == len);

sigma = r / 3.0;
g = exp(-[-r : r] .^ 2 / (2 * sigma * sigma));
g = g ./ g(r + 1);

end
