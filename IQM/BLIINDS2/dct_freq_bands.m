function f = dct_freq_bands(In)
    I=dct2(In.data);
    eps=1e-8;
    % 5x5 freq band x3
    % NOTE: the top left element IS ignored
    var_band1 = var(I(logical([0 1 1 0 0; 1 1 0 0 0; 1 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0])));
    var_band2 = var(I(logical([0 0 0 1 1; 0 0 1 1 1; 0 1 1 1 0; 1 1 1 0 0; 1 1 0 0 0])));
    var_band3 = var(I(logical([0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 1; 0 0 0 1 1; 0 0 1 1 1])));
    m = mean([var_band1 var_band2]);
    r1 = abs(var_band3 - m)/(var_band3 + m + eps);
    r2 = abs(var_band2 - var_band1)/(var_band3 + var_band1 + eps);
    f = (r1+r2)/2;
end
