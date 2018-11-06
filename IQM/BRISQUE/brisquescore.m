function qualityscore  = brisquescore(img)
    %% Check input
    assert(size(img, 3) == 1);
    assert(isa(img, 'double'));
    %% TODO
    error('Unimplemented');
    %% Compute
    path_this = fileparts(which(mfilename));
    old_pwd = pwd;
    cd(path_this);
    % Prepare input for LibSVM
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
    % Call LibSVM
    delete output
    system('svm-scale -r all.scale test >test.scaled');
    system('svm-predict -b 1 test.scaled all.model output.mat >dump');
    qualityscore = load('output.mat');
    assert(isnumeric(qualityscore));
    cd(old_pwd);
end
