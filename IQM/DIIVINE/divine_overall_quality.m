function score = divine_overall_quality(r)
% Function to compute overall quality given feature vector 'r'
    load('data_live_trained.mat', 'model_class', 'a_class', 'b_class', 'a_reg', 'b_reg', 'model_reg');
    %% Classification
    atrain = repmat(a_class,[size(r,1) 1]);btrain = repmat(b_class,[size(r,1) 1]);
    x_curr = atrain .* r + btrain;
    [~, ~, ~, p] = evalc('svmpredict(1, x_curr, model_class, ''-b 1'');'); % evalc to suppress console output
    %% Regression
    q = zeros(1, 5);
    for i = 1:5
        atrain = repmat(a_reg(i,:), [size(r,1) 1]);
        btrain = repmat(b_reg(i,:), [size(r,1) 1]);
        x_curr = atrain .* r + btrain;
        [~, q(i), reg_acc(i,:)] = evalc('svmpredict(1, x_curr, model_reg{i})'); % evalc to suppress console output
    end
    %% Final Score
    score = sum(p .* q);
end
