function rho = rho_dct(I)
    block = dct2(I.data);
    block = abs(block(2:end)');
    rho = std(block) / (mean(block)+0.0000001);
end
