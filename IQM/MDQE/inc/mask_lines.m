function mask = mask_lines(img)

if size(img, 3) > 1
    img = rgb2gray(img);
end

mask = false(size(img));
e = edge(img, 'canny');

filter = ones(3, 3);
for i = 1 : 20
    cur_mask = mask_line(e);
    e(cur_mask) = false;

    cur_mask = conv2(double(cur_mask), filter, 'same');
    cur_mask = cur_mask > 0;

    mask(cur_mask) = true;
end

end
