function names = iqm_names()
%IQM_NAMES Return A cell array of char arrays.
%   Each char array represents an available metric name, valid as input to iqm()
	global iqm_function_handles;
    names = keys(iqm_function_handles);
end

