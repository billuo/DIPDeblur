function g1 = oriented1_dct_rho_config3(I)
    block=dct2(I.data);
    block=abs(block(logical([0 1 1 1 1; 0 0 1 1 1; 0 0 0 0 1; 0 0 0 0 0; 0 0 0 0 0])));
    std_gauss=std(block);
    mean_abs=mean(block);
    g1=std_gauss/(mean_abs+0.0000001);
end
