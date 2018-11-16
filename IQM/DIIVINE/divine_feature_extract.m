function f = divine_feature_extract(im)
% Function to extract features given an image
    f = [];
    assert(size(im, 3) == 1);
%     if(size(im,3)~=1)
%         im = (double(rgb2gray(im)));
%     end
    %% Constants
    num_or = 6;
    num_scales = 2;
    gam = 0.2:0.001:10;
    r_gam = gamma(1./gam).*gamma(3./gam)./(gamma(2./gam)).^2;
    %% Wavelet Transform +  Div. Norm.
    [pyr, pind] = buildSFpyr(im,num_scales,num_or-1);
    [subband, size_band] = norm_sender_normalized(pyr,pind,num_scales,num_or,1,1,3,3,50);
    %% Marginal Statistics
    sigma_sq_horz = zeros(1, length(subband));
    gam_horz = zeros(1, length(subband));
    for ii = 1:length(subband)
        t = subband{ii};
        mu_horz = mean(t);
        sigma_sq_horz(ii) = mean((t-mu_horz).^2);
        E_horz = mean(abs(t-mu_horz));
        rho_horz = sigma_sq_horz(ii)/E_horz^2;
        [~, array_position] = min(abs(rho_horz - r_gam));
        gam_horz(ii) = gam(array_position);    
    end
    f = [f sigma_sq_horz gam_horz]; % ind. subband stats f1-f24
    %% Joint Statistics
    clear sigma_sq_horz gam_horz
    for ii = 1:length(subband)/2
        t = [subband{ii}; subband{ii+num_or}];
        mu_horz = mean(t);
        sigma_sq_horz(ii) = mean((t-mu_horz).^2);
        E_horz = mean(abs(t-mu_horz));
        rho_horz = sigma_sq_horz(ii)/E_horz^2;
        [~, array_position] = min(abs(rho_horz - r_gam));
        gam_horz(ii) = gam(array_position);
    end
    f = [f gam_horz];

    t = cell2mat(subband');
    sigma_sq = mean((t-mu_horz).^2);
    E_horz = mean(abs(t-mu_horz));
    rho_horz = sigma_sq/E_horz^2;
    [~, array_position] = min(abs(rho_horz - r_gam));
    gam_horz = gam(array_position);
    f = [f gam_horz];
    %% Hp-BP correlations
    hp_band = pyrBand(pyr,pind,1);
    cs_val = zeros(1, length(subband));
    for ii = 1:length(subband)
        curr_band = pyrBand(pyr,pind,ii+1);
        [~, ~, cs_val(ii)] = ssim_index_new(imresize(curr_band,size(hp_band)),hp_band);
    end
    f = [f cs_val];
    %% Spatial Correlation
    b = zeros(5, floor(length(subband)/2));
    tic;
    for i = 1:length(subband)/2
        b(:, i) = find_spatial_hist_fast(reshape(subband{i},(size_band(i,:)))); % OPT
    end
    toc;
    f = [f b(:)'];
    %%  Orientation feature...
    clear cs_val
    l = 1;
    for i = 1:length(subband)/2
        for j = i+1:length(subband)/2
          [~, ~, cs_val(l)] = ssim_index_new(reshape(subband{i},size_band(i,:)),reshape(subband{j},size_band(j,:)));  
          l = l + 1;
        end
    end
    f = [f cs_val];
end
