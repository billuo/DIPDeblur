function iqm_test()
% Test computing all supported image quality metrics one by one.
    disp('Starting testing...');
    n_errors = 0;
    %% Read test images
    img = imread('blurred.png');
    img_ref = imread('deblurred.png');
    disp('Image loaded.');
    assert(~isa(img, 'double') && size(img, 3) == 3 && mean(mean2(img)) > 1);
    disp('Iterating through all metrics...');
    %% Iteration
    global iqm_function_handles;
    counter = 0;
    for name = keys(iqm_function_handles)
        counter = counter + 1;
        try
            assert(~isa(img, 'double') && size(img, 3) == 3 && mean(mean2(img)) > 1, 'Image invalidated!');
            fprintf('%2i.%-8s ', counter, name{1});
            fprintf('Result: %8.2f  Success!\n', iqm(name{1}, img, img_ref));
        catch ME
            warning('on');
            warning('%s\n\t%s FAILED\n', getReport(ME), name{1});
            n_errors = n_errors + 1;
        end
    end
    %% Conclude
    if n_errors == 0
        fprintf('\tALL PASSED!');
    else
        error('Number of error: %i\n', n_errors);
    end
end
