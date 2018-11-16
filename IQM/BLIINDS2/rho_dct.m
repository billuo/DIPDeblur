function rho = rho_dct(I)

block=dct2(I.data);
block = abs(block(2:end)');

std_gauss = std(block);
mean_abs = mean(block);
rho=std_gauss/(mean_abs+0.0000001);
