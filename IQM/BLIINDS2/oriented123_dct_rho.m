function g123 = oriented123_dct_rho(I)
    % g123 is of size 1,1,3. When concated alone height and width by
    % blockproc, it produces a matrix of size h,w,3.
    block = dct2(I.data);
    mask1 = logical([0 1 1 1 1; 0 0 1 1 1; 0 0 0 0 1; 0 0 0 0 0; 0 0 0 0 0]);
    mask2 = logical([0 0 0 0 0; 0 1 0 0 0; 0 0 1 1 0; 0 0 1 1 1; 0 0 0 1 1]);
    mask3 = logical([0 0 0 0 0; 1 0 0 0 0; 1 1 0 0 0; 1 1 0 0 0; 1 1 1 0 0]);
    block123 = [abs(block(mask1)), abs(block(mask2)), abs(block(mask3))];
    g123 = reshape(std(block123, 0) ./ (mean(block123)+0.0000001), [1, 1, 3]);
end
