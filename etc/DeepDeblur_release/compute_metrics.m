%% input/output directory and CRF type
blurred_img_dir = fullfile('dataset', 'GOPRO_Large', 'test');
deblurred_img_dir = fullfile('deblur_output');
kernel_type = 'blur_gamma';
%% metric name constants
% metrics = iqm_names();
metrics = ["PSNR", "WSNR", "SSIM", "MSSSIM", "IFC", "NQM", "UIQI", "VIF", ...
        "BIQI", "BLIINDS2", "BRISQUE", "CORNIA", "DIIVINE", "NIQE", "SSEQ", "MDQE"];
n_metrics = numel(metrics);
%% check if blurred images match with deblurred ones, total them by the way
n_imgs = 0;
for subdir = dir(fullfile(blurred_img_dir, 'GO*'))'
    if ~subdir.isdir
        continue
    end
    subdir_ref = fullfile(deblurred_img_dir, subdir.name);
    assert(exist(subdir_ref, 'dir') ~= 0, ...
        'Under deblurred image directory, folder ''%s'' not found', subdir.name);
    for blurred = dir(fullfile(blurred_img_dir, subdir.name, kernel_type, '*.png'))'
        deblurred = fullfile(subdir_ref, kernel_type, blurred.name);
        assert(exist(deblurred, 'file') ~= 0, ...
            'Under deblurred image subdirectory, image ''%s'' not found', blurred.name);
        n_imgs = n_imgs + 1;
    end
end
fprintf('Found %d images pair in total.\n', n_imgs);
%% compute them
fprintf('Computing %d metrics.\n', n_metrics);
n_imgs = 0;
for subdir = dir(fullfile(blurred_img_dir, 'GO*'))'
    if ~subdir.isdir
        continue
    end
    subdir_ref = fullfile(deblurred_img_dir, subdir.name);
    mat_file = sprintf('%s.mat', fullfile(subdir.folder, subdir.name));
    if exist(mat_file, 'file') ~= 0
        continue
    end
    M = [];
    for blurred = dir(fullfile(blurred_img_dir, subdir.name, kernel_type, '*.png'))'
        n_imgs = n_imgs + 1;
        blurred_img = fullfile(blurred.folder, blurred.name);
        deblurred_img = fullfile(subdir_ref, kernel_type, blurred.name);
        fprintf('Computing image#%d...', n_imgs);
        tic;
        m = zeros(1, n_metrics);
        for k = 1:n_metrics
            m(k) = iqm(metrics(k), blurred_img, deblurred_img);
        end
        M = [M; m];
        fprintf('\tUsed %f seconds\n', toc);
    end
    save(mat_file, 'M');
end
