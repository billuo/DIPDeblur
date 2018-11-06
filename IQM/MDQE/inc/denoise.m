function denoised = denoise(img)

THRESHOLD = 0.01;
LOW       = 0.0;
HIGH      = 0.5; 
MIN_STEP  = 0.0005;

cont = true;

result = [];
[denoised, err] = bm3d_twocolor(img, LOW);
result = cat(1, result, [LOW, err]);
if err <= THRESHOLD
    cont = false;
end

if cont 
    [denoised, err] = bm3d_twocolor(img, HIGH);
    result = cat(1, result, [HIGH, err]);
    if err > THRESHOLD
        cont = false;
    end
end

cur_low  = LOW;
cur_high = HIGH;
while cont
    cur = (cur_low + cur_high) * 0.5;
    [denoised, err] = bm3d_twocolor(img, cur);
    %fprintf('cur = %f, err = %f\n', cur, err);
    result = cat(1, result, [cur, err]);

    if (err <= THRESHOLD)
        cur_high = cur;
    elseif (err > THRESHOLD)
        cur_low  = cur;
    end

    if (cur_low + MIN_STEP >= cur_high)
        idx = find(abs(result(:, 1) - cur_high) < 1e-6, 1);
        assert(~isempty(idx));

        [denoised, err] = bm3d_twocolor(img, cur_high);
        result = cat(1, result, [cur_high, err]);
        cont = false;
    end
end

end



function [denoised, err] = bm3d_twocolor(img, noise_level)

if noise_level > 1e-6
    [~, denoised] = CBM3D(1, img, noise_level * 255);
else
    denoised = img;
end
[~, ~, err] = two_color(denoised);
err = (mean(err(:) .^ 0.8)) ^ (1 / 0.8);

end
