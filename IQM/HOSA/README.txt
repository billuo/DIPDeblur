For questions concerning the code please contact Jingtao Xu (xjt678 AT gmail DOT com). 

If you find this software useful for your research, please cite the following paper.
@ARTICLE{jingtaoxu-2016
author={J. Xu and P. Ye and Q. Li and H. Du and Y. Liu and D. Doermann},
journal={IEEE Transactions on Image Processing},
title={Blind Image Quality Assessment based on High Order Statistics Aggregation},
year={2016},
volume={PP},
number={99},
pages={1-1},
doi={10.1109/TIP.2016.2585880},
ISSN={1057-7149},
month={},}

------------------------------------------------------
Descriptions :
------------------------------------------------------
hosa_feature_extraction.m -- extract hosa feature for a testing image
example.m -- examples of how use the code to compute quality scores of a testing image

codebook_hosa.mat -- high order statistics codebook extracted from CSIQ database http://vision.okstate.edu/?loc=csiq
whitening_param.mat -- whitening parameters obtained on CSIQ database
hosa_live_model.mat -- trained model on LIVE database

For training on all 24 distortions in TID2013 database, the parameter C of LIBLINEAR is 1. For other experiments, C is usually 128. 