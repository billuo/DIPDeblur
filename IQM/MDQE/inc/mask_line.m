function mask = mask_line(e)

[H, theta, rho] = hough(e, 'Theta', -90:0.5:89.5);
P = houghpeaks(H, 2, 'threshold', ceil(0.2 * max(H(:))));
lines = houghlines(e, theta, rho, P, 'FillGap', 8, 'Minlength', 20);

len = ceil(max(size(e)) * 3);
mask = false(size(e));
for k = 1 : length(lines)
    if isempty(fieldnames(lines(k)))
        break;
    end
    xy = [lines(k).point1; lines(k).point2];
    
    xs = linspace(xy(1, 1), xy(2, 1), len);
    ys = linspace(xy(1, 2), xy(2, 2), len);

    mask = mask_points(mask, floor(xs), floor(ys));
    mask = mask_points(mask, floor(xs), ceil (ys));
    mask = mask_points(mask, ceil (xs), floor(ys));
    mask = mask_points(mask, ceil (xs), ceil (ys));
end

end


function mask = mask_points(mask, xs, ys)

indices = sub2ind(size(mask), ys, xs);
mask(indices) = true;

end
