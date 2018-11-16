function g2 = oriented2_dct_rho_config3(I)
    block=dct2(I.data);
    block=abs(block(logical([0 0 0 0 0; 0 1 0 0 0; 0 0 1 1 0; 0 0 1 1 1; 0 0 0 1 1])));
    std_gauss=std(block);
    mean_abs=mean(block);
    g2=std_gauss/(mean_abs+0.0000001);
end
