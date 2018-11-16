function [time, metric] = iqm_time(name, img, img_ref)
% IQM_TIME the same as iqm, but in addition to the metric value return the
% time consumed in seconds in front of it.
    tic;
    metric = iqm(name, img, img_ref);
    time = toc;
end
