function predicted_score = bliinds_prediction(features)

    % features: needs to be a ROW vector of features
    b = 1.0168;
    gama = 0.4200;
    load('mu_sigma_inv.mat', 'mu', 'sigma_inv');

    count = 0;
    current_max = -inf;
    for i = 1:0.5:100
        count = count + 1;
        d = [features, i] - mu;
        p = exp(-(b * (d * sigma_inv * d'))^gama);
        if p > current_max
            index_max = count;
            current_max = p;
        end
    end
    iVect = 0:0.5:100;
    predicted_score = iVect(index_max);
end
