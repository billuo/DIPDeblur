% main
clear
img = imread('img215.bmp');
img = rgb2gray(img);
% load codebook
load('CSIQ_codebook_BS7.mat','codebook0');
load('LIVE_soft_svm_model.mat','soft_model','soft_scale_param');
% load whitening parameter
load('CSIQ_whitening_param.mat','M','P');

svm_model = soft_model;
svm_scale = soft_scale_param;

score = cornia(img, codebook0, 'soft', svm_model, svm_scale, M, P);

