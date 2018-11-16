function gamma_gauss = gama_dct(I)
    img = dct2(I.data);
    img = img(2:end)';

    mean_gauss = mean(img);
    var_gauss = var(img);
    mean_abs = mean(abs(img - mean_gauss))^2;
    rho = var_gauss / (mean_abs+0.0000001);

    g = 0.03:0.001:10;
    r = gamma(1./g).*gamma(3./g)./(gamma(2./g).^2);
    %% corner cases
    if rho > r(1) || r(end) >= rho
        gamma_gauss = 11;
        return
    end
    for i = 1:numel(g)-1
        if r(i) >= rho && rho > r(i+1)
            gamma_gauss = g(i);
            break
        end
    end
end
