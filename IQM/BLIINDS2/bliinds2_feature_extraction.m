function features = bliinds2_feature_extraction(Img)
    assert(isa(Img, 'double'));
    assert(size(Img, 3) == 1);
    %% constants
    h=fspecial('gaussian',3);
    %%% for interp1() usage
    g = 0.03:0.001:10;
    r = gamma(1./g).*gamma(3./g)./(gamma(2./g).^2);
    g(end) = 11;
    %%
    coeff_freq_var_L1 = blockproc(Img,[3,3],@rho_dct, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true);
    gama_L1 = blockproc(Img, [3,3], @gama_dct, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true);
    gama_L1(:) = interp1([r, realmax], [g, 11], gama_L1(:), 'next', 'extrap');
    %%% These three shall be returned in one blockproc... return three
    %%% values as a vector on depth dimension!
    ori1_rho_L1 = blockproc(Img,[3 3],@oriented1_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    ori2_rho_L1 = blockproc(Img,[3 3],@oriented2_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    ori3_rho_L1 = blockproc(Img,[3 3],@oriented3_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true); 
    ori_rho_L1 = reshape(var([ori1_rho_L1(:), ori2_rho_L1(:), ori3_rho_L1(:)], 0, 2), size(ori1_rho_L1));
    subband_energy_L1 = blockproc(Img,[3 3],@dct_freq_bands, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    
    rho_sorted_temp = sort(coeff_freq_var_L1(:),'descend');
    rho_count = length(rho_sorted_temp);
    percentile10_coeff_freq_var_L1=mean(rho_sorted_temp(1:ceil(rho_count/10)));
    percentile100_coeff_freq_var_L1=mean(rho_sorted_temp(:));
    %clear rho_sorted_temp rho_count
    
    gama_sorted_temp = sort(gama_L1(:),'ascend');
    gama_count = length(gama_sorted_temp);
    percentile10_gama_L1=mean(gama_sorted_temp(1:ceil(gama_count/10)));
    percentile100_gama_L1=mean(gama_sorted_temp(:));
    %clear gama_sorted_temp gama_count
    
    subband_energy_sorted_temp = sort(subband_energy_L1(:),'descend');
    subband_energy_count = length(subband_energy_sorted_temp);
    percentile10_subband_energy_L1=mean(subband_energy_sorted_temp(1:ceil(subband_energy_count/10)));
    percentile100_subband_energy_L1=mean(subband_energy_sorted_temp(:));

    
    ori_sorted_temp = sort(ori_rho_L1(:),'descend');
    ori_count = length(ori_sorted_temp);
    percentile10_orientation_L1=mean(ori_sorted_temp(1:ceil(ori_count/10)));
    percentile100_orientation_L1=mean(ori_sorted_temp(:));
    %clear var_ori_sorted_temp rho_count
    
    features_L1 = [percentile100_coeff_freq_var_L1;percentile10_coeff_freq_var_L1;percentile100_gama_L1;percentile10_gama_L1;percentile100_subband_energy_L1;percentile10_subband_energy_L1;percentile100_orientation_L1;percentile10_orientation_L1];
    
    %%
    Img1_filtered=double(imfilter(Img,h));
    Img2 = Img1_filtered(2:2:end,2:2:end);
    
    coeff_freq_var_L2 = blockproc(Img2,[3,3],@rho_dct, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true);
    gama_L2 = blockproc(Img2,[3,3],@gama_dct,'BorderSize',[1,1], 'TrimBorder', false, 'UseParallel', true);
    gama_L2(:) = interp1([r, realmax], [g, 11], gama_L2(:), 'next', 'extrap');
    ori1_rho_L2 = blockproc(Img2,[3 3],@oriented1_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    ori2_rho_L2 = blockproc(Img2,[3 3],@oriented2_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    ori3_rho_L2 = blockproc(Img2,[3 3],@oriented3_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    subband_energy_L2 = blockproc(Img2,[3 3],@dct_freq_bands, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    
    rho_sorted_temp = sort(coeff_freq_var_L2(:),'descend');
    rho_count = length(rho_sorted_temp);
    percentile10_coeff_freq_var_L2=mean(rho_sorted_temp(1:ceil(rho_count/10)));
    percentile100_coeff_freq_var_L2=mean(rho_sorted_temp(:));
    %clear rho_sorted_temp rho_count
    
    gama_sorted_temp = sort(gama_L2(:),'ascend');
    gama_count = length(gama_sorted_temp);
    percentile10_gama_L2=mean(gama_sorted_temp(1:ceil(gama_count/10)));
    percentile100_gama_L2=mean(gama_sorted_temp(:));
    %clear gama_sorted_temp gama_count
    
    subband_energy_sorted_temp = sort(subband_energy_L2(:),'descend');
    subband_energy_count = length(subband_energy_sorted_temp);
    percentile10_subband_energy_L2=mean(subband_energy_sorted_temp(1:ceil(subband_energy_count/10)));
    percentile100_subband_energy_L2=mean(subband_energy_sorted_temp(:));
    
    ori_rho_L2 = reshape(var([ori1_rho_L2(:), ori2_rho_L2(:), ori3_rho_L2(:)], 0, 2), size(ori1_rho_L2));
    
    ori_sorted_temp = sort(ori_rho_L2(:),'descend');
    ori_count = length(ori_sorted_temp);
    percentile10_orientation_L2=mean(ori_sorted_temp(1:ceil(ori_count/10)));
    percentile100_orientation_L2=mean(ori_sorted_temp(:));
    %clear var_ori_sorted_temp rho_count
    
    features_L2 = [percentile100_coeff_freq_var_L2;percentile10_coeff_freq_var_L2;percentile100_gama_L2;percentile10_gama_L2;percentile100_subband_energy_L2;percentile10_subband_energy_L2;percentile100_orientation_L2;percentile10_orientation_L2];
    
    %%
    Img2_filtered=double(imfilter(Img2,h));
    Img3 = Img2_filtered(2:2:end,2:2:end);
    
    coeff_freq_var_L3 = blockproc(Img3,[3,3],@rho_dct, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true);
    gama_L3 = blockproc(Img3,[3,3],@gama_dct,'BorderSize',[1,1], 'TrimBorder', false, 'UseParallel', true);
    gama_L3(:) = interp1([r, realmax], [g, 11], gama_L3(:), 'next', 'extrap');
    ori1_rho_L3 = blockproc(Img3,[3 3],@oriented1_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    ori2_rho_L3 = blockproc(Img3,[3 3],@oriented2_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    ori3_rho_L3 = blockproc(Img3,[3 3],@oriented3_dct_rho_config3, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    subband_energy_L3 = blockproc(Img3,[3 3],@dct_freq_bands, 'BorderSize', [1,1], 'TrimBorder', false, 'UseParallel', true, 'PadPartialBlocks', true);
    
    rho_sorted_temp = sort(coeff_freq_var_L3(:),'descend');
    rho_count = length(rho_sorted_temp);
    percentile10_coeff_freq_var_L3=mean(rho_sorted_temp(1:ceil(rho_count/10)));
    percentile100_coeff_freq_var_L3=mean(rho_sorted_temp(:));
    %clear rho_sorted_temp rho_count
    
    gama_sorted_temp = sort(gama_L3(:),'ascend');
    gama_count = length(gama_sorted_temp);
    percentile10_gama_L3=mean(gama_sorted_temp(1:ceil(gama_count/10)));
    percentile100_gama_L3=mean(gama_sorted_temp(:));
    %clear gama_sorted_temp gama_count
    
    subband_energy_sorted_temp = sort(subband_energy_L3(:),'descend');
    subband_energy_count = length(subband_energy_sorted_temp);
    percentile10_subband_energy_L3=mean(subband_energy_sorted_temp(1:ceil(subband_energy_count/10)));
    percentile100_subband_energy_L3=mean(subband_energy_sorted_temp(:));
    
    ori_rho_L3 = reshape(var([ori1_rho_L3(:), ori2_rho_L3(:), ori3_rho_L3(:)], 0, 2), size(ori1_rho_L3));
    
    ori_sorted_temp = sort(ori_rho_L3(:),'descend');
    ori_count = length(ori_sorted_temp);
    percentile10_orientation_L3=mean(ori_sorted_temp(1:ceil(ori_count/10)));
    percentile100_orientation_L3=mean(ori_sorted_temp(:));
    %clear var_ori_sorted_temp rho_count
    
    features_L3 = [percentile100_coeff_freq_var_L3;percentile10_coeff_freq_var_L3;percentile100_gama_L3;percentile10_gama_L3;percentile100_subband_energy_L3;percentile10_subband_energy_L3;percentile100_orientation_L3;percentile10_orientation_L3];
    
    %%
    features = [features_L1 features_L2 features_L3];
end
