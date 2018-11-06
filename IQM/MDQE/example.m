% this metric uses BM3D for denoising
disp('Adding path...');
addpath inc
addpath inc/BM3D

% load the deblurring result
disp('Reading images...');
deblurred = im2double(imread('deblurred.png'));
blurred   = im2double(imread('blurry.png'));

% evaluate the image quality. larger value means higher quality.
disp('Measuring quality...');
quality = measure(deblurred, blurred);

fprintf(1, 'quality = %0.12f\n', quality);
