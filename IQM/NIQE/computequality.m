function  quality = computequality(im,blocksizerow,blocksizecol,...
    blockrowoverlap,blockcoloverlap,mu_prisparam,cov_prisparam)
   
% Input
% im              - Image whose quality needs to be computed
% blocksizerow    - Height of the blocks in to which image is divided
% blocksizecol    - Width of the blocks in to which image is divided
% blockrowoverlap - Amount of vertical overlap between blocks
% blockcoloverlap - Amount of horizontal overlap between blocks
% mu_prisparam    - mean of multivariate Gaussian model
% cov_prisparam   - covariance of multivariate Gaussian model

% For good performance, it is advisable to use make the multivariate Gaussian model
% using same size patches as the distorted image is divided in to

% Output
%quality      - Quality of the input distorted image

% Example call
%quality = computequality(im,96,96,0,0,mu_prisparam,cov_prisparam)

% ---------------------------------------------------------------
%Number of features
% 18 features at each scale
featnum      = 18;
%----------------------------------------------------------------
%Compute features
assert(size(im, 3) == 1);
assert(isa(im, 'double'));

[row, col] = size(im);
block_rownum = floor(row/blocksizerow);
block_colnum = floor(col/blocksizecol);
im = im(1:block_rownum * blocksizerow, 1:block_colnum * blocksizecol); 

[row, col] = size(im);
block_rownum = floor(row/blocksizerow);
block_colnum = floor(col/blocksizecol);
im = im(1:block_rownum * blocksizerow, 1:block_colnum * blocksizecol);  

window           = fspecial('gaussian',7,7/6);
window           = window/sum(sum(window));
scalenum         = 2;


feat             = [];


for itr_scale = 1:scalenum

    
mu                       = imfilter(im,window,'replicate');
mu_sq                    = mu.*mu;
sigma                    = sqrt(abs(imfilter(im.*im,window,'replicate') - mu_sq));
structdis                = (im-mu)./(sigma+1);
              
               
               
feat_scale               = blkproc(structdis,[blocksizerow/itr_scale blocksizecol/itr_scale], ...
                           [blockrowoverlap/itr_scale blockcoloverlap/itr_scale], ...
                           @computefeature);
feat_scale               = reshape(feat_scale,[featnum ....
                           size(feat_scale,1)*size(feat_scale,2)/featnum]);
feat_scale               = feat_scale';


if(itr_scale == 1)
sharpness                = blkproc(sigma,[blocksizerow blocksizecol], ...
                           [blockrowoverlap blockcoloverlap],@computemean);
sharpness                = sharpness(:);
end


feat                     = [feat feat_scale];
%dbstop if any(reshape(isnan(feat), 1, []))
if any(reshape(isnan(feat), 1, []))
    error('itr_scale=%i', itr_scale);
end
im =imresize(im,0.5);

end


% Fit a MVG model to distorted patch features
distparam        = feat;

mu_distparam     = nanmean(distparam);
cov_distparam    = nancov(distparam);

% Compute quality
pinv_arg = (cov_prisparam+cov_distparam)/2;
assert(~any(reshape(isnan(pinv_arg), 1, [])));
invcov_param     = pinv(pinv_arg);
quality = sqrt((mu_prisparam-mu_distparam)* ...
    invcov_param*(mu_prisparam-mu_distparam)');
