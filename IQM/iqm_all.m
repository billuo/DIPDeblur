function metrics = iqm_all(img, img_ref)
% IQM_ALL Given a pair of image and reference image,
% compute and store all metrics in an array of double.
%
% The order of returned values are correspondent with that in the
% cell array of char arrays returned by iqm_names().
% i.e. This function effectively computes:
%   for i = 1 : numel(iqm_names())
%       image_metrics(i) = iqm(iqm_names(){i}, img, img_ref);
    names = iqm_names();
    n = numel(names);
    metrics = zeros(1, n);
    time_usage = 0;
    for i = 1:n
        fprintf('Evaluating metric %s\n', names{i});
        [t, metrics(i)] = iqm_time(names{i}, img, img_ref);
        time_usage = time_usage + t;
        fprintf('\tFinished after %f seconds\n', t);
    end
    fprintf('Total time usage: %f seconds\n', time_usage);
end

