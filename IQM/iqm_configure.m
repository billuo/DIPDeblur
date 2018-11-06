function iqm_configure()
% IQM_CONFIGURE Configure Matlab search path and load various function handles.
% Need to be called every time Matlab starts up (for now).
%% Add current folder to Matlab search path
fprintf('Adding search path\n');
global iqm_path;
[iqm_path, ~, ~] = fileparts(which(mfilename));
old_warning_struct = warning;
warning('off');
rmpath(genpath(iqm_path));
warning(old_warning_struct);
addpath(iqm_path);
savepath(); % only save the path to this file
addpath(genpath(fullfile(iqm_path, 'Utilities')));
%% Initialize name-handle map
names = ["MSE", "SNR", "PSNR", "WSNR", "VSNR", "SSIM", "MSSSIM", "VIF", "VIFP", "IFC", "NQM", "UIQI", ... <-FR
    "NIQE", "MDQE"]; %, "BLIINDS2"]; % <- NR
%% These are untackled: they all depend on LibSVM.
% TODO: Integrate a SINGLE copy of svm executables into this project.
% names = [names, "BRISQUE", "DIIVINE", "SSEQ", "BIQI", "CORNIA"];
%% Initialize handle map
global iqm_function_handles;
iqm_function_handles = containers.Map;
for name = names
    iqm_function_handles(char(name)) = eval(['@iqm_', lower(char(name))]);
end
%% Test them
iqm_test();
end

%#ok<*DEFNU> %functions below are mostly called through handles
%% Implemented trivially
function [MSE] = iqm_mse(img, img_ref)
    MSE = mean(mean2((img - img_ref).^2));
end

function [SNR] = iqm_snr(img, img_ref)
    [~, SNR] = psnr(img, img_ref, 255);
end

function [PSNR] = iqm_psnr(img, img_ref)
    assert(mean(mean2(img)) > 1);
    [PSNR, ~] = psnr(img, img_ref, 255);
end

%% Bindings to sub-modules
function [WSNR] = iqm_wsnr(img, img_ref)
    global iqm_path;
    module_name = 'NQM';
    addpath(genpath(fullfile(iqm_path, module_name)));
    WSNR = wsnr_new_modified(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [VSNR] = iqm_vsnr(img, img_ref)
    global iqm_path;
    module_name = 'VSNR';
    addpath(genpath(fullfile(iqm_path, module_name)));
    VSNR = vsnr_modified(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [SSIM] = iqm_ssim(img, img_ref)
    global iqm_path;
    module_name = 'SSIM';
    addpath(genpath(fullfile(iqm_path, module_name)));
    SSIM = ssim_index(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [MSSSIM] = iqm_msssim(img, img_ref)
    global iqm_path;
    module_name = 'MSSSIM';
    addpath(genpath(fullfile(iqm_path, module_name)));
    MSSSIM = mssim_index(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [VIF] = iqm_vif(img, img_ref)
    global iqm_path;
    module_name = 'VIF';
    addpath(genpath(fullfile(iqm_path, module_name)));
    VIF = vifvec(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [VIFP] = iqm_vifp(img, img_ref)
    global iqm_path;
    module_name = 'VIFP';
    addpath(genpath(fullfile(iqm_path, module_name)));
    VIFP = vifp_mscale(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [IFC] = iqm_ifc(img, img_ref)
    global iqm_path;
    module_name = 'IFC';
    addpath(genpath(fullfile(iqm_path, module_name)));
    IFC = ifcvec(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [NQM] = iqm_nqm(img, img_ref)
    global iqm_path;
    module_name = 'NQM';
    addpath(genpath(fullfile(iqm_path, module_name)));
    % Viewing angle (in degrees) is determined based on the assumption that
    % the image is viewed at 3.5 picture heights away
    viewing_angle = 1/3.5 * 180 / pi;
    % Estimate the dimesion of the image with the geometric mean
    % of the horizonal and vertical dimensions
    dim = sqrt(numel(img_ref));
    NQM = nqm_modified(img_ref, img, viewing_angle, dim);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [UIQI] = iqm_uiqi(img, img_ref)
    global iqm_path;
    module_name = 'UIQI';
    addpath(genpath(fullfile(iqm_path, module_name)));
    UIQI = img_qi(img_ref, img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [BLIINDS2] = iqm_bliinds2(img)
    global iqm_path;
    module_name = 'BLIINDS2';
    addpath(genpath(fullfile(iqm_path, module_name)));
    features = bliinds2_feature_extraction(img);
    BLIINDS2 = bliinds_prediction(features(:)');
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [BRISQUE] = iqm_brisque(img)
    global iqm_path;
    module_name = 'BRISQUE';
    addpath(genpath(fullfile(iqm_path, module_name)));
    BRISQUE = brisquescore(img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [NIQE] = iqm_niqe(img)
    global iqm_path;
    module_name = 'NIQE';
    addpath(genpath(fullfile(iqm_path, module_name)));
    load('modelparameters.mat', 'mu_prisparam', 'cov_prisparam');
    blocksizerow = 96;
    blocksizecol = 96;
    blockrowoverlap = 0;
    blockcoloverlap = 0;
    NIQE = computequality(img, blocksizerow, blocksizecol, blockrowoverlap, blockcoloverlap, ...
        mu_prisparam, cov_prisparam);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [DIIVINE] = iqm_diivine(img)
    global iqm_path;
    module_name = 'DIIVINE';
    addpath(genpath(fullfile(iqm_path, module_name)));
    assert(size(img, 3) == 1);
    DIIVINE = divine(img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [SSEQ] = iqm_sseq(img)
    global iqm_path;
    module_name = 'SSEQ';
    addpath(genpath(fullfile(iqm_path, module_name)));
    SSEQ = sseq(img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

function [MDQE] = iqm_mdqe(img_blurred, img_deblurred)
    global iqm_path;
    module_name = 'MDQE';
    assert(size(img_blurred, 3) == 3);
    assert(size(img_deblurred, 3) == 3);
    assert(mean(mean2(img_blurred)) <= 1, sprintf('mean=%f\n', mean2(img_blurred)));
    assert(mean(mean2(img_deblurred)) <= 1, sprintf('mean=%f\n', mean2(img_deblurred)));
    addpath(genpath(fullfile(iqm_path, module_name)));
    MDQE = measure(img_deblurred, img_blurred);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end

%{
function [] = iqm_(img)
    global iqm_path;
    module_name = '';
    addpath(genpath(fullfile(iqm_path, module_name)));
     = (img);
    rmpath(genpath(fullfile(iqm_path, module_name)));
end
%}
