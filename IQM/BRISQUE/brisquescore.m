function qualityscore  = brisquescore(img)
    %% Check input
    assert(size(img, 3) == 1);
    assert(isa(img, 'double'));
    %% Compute
    old_cd = cd(fileparts(which(mfilename)));
    if exist('output', 'file')
        delete output
    end
    %%% Prepare input for LibSVM
    feat = brisque_feature(img);
    fid = fopen('test', 'w');
    for jj = 1:size(feat, 1)
        fprintf(fid, '1 ');
        for kk = 1:size(feat, 2)
            fprintf(fid, '%d:%f ', kk, feat(jj, kk));
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
    %%% Call LibSVM
    global iqm_svm_scale;
    global iqm_svm_predict;

    system([iqm_svm_scale ' -r all.scale test >test.scaled']);
    system([iqm_svm_predict ' -b 1 test.scaled all.model output >dump']);
    qualityscore = load('output', '-ascii');
    assert(isnumeric(qualityscore));
    cd(old_cd);
end
