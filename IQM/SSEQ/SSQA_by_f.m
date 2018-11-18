function score = SSQA_by_f( feature)
    load('model.mat', 'fmax', 'fmin', 'svmmodel', 'svrmodel');
    feature =setscale(feature,fmax,fmin);
    [~, ~, p] = svmpredict_old(ones(1,1), feature, svmmodel,'-b 1 -q'); % use the old version
    q=zeros(1,5);
    for j=1:5
        q(:, j) = svmpredict_old(ones(1,1), feature, svrmodel{j}, '-q'); % use the old version
    end
    Q=sum(p.*q , 2);
    score=Q*50+50;
end

