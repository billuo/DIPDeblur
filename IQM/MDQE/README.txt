Readme of Our Source Code

Yiming Liu
yimingl@cs.princeton.edu


Overview
========

This is a Matlab implementation of our SIGGRAPH Asia 2013 paper 'A No-Reference
Metric for Evaluating the Quality of Motion Deblurring'.


Setup
=====

Our metric uses BM3D for denosing. The license of BM3D does not allow us to
publish our metric with it on the Internet. You have to download it at
http://www.cs.tut.fi/~foi/GCF-BM3D/BM3D.zip, and extract it to inc/BM3D. 


Interface
=========

function [score, details] = measure(deblurred, blurred)
%
% Input arguments:
%  * deblurred: the deblurring result. It should be a three-channel RGB image.
%    The pixel value should be within [0.0, 1.0].
%  * blurred: the blurry image (the input of the deblurring algorithm). It
%    should also be a three-channel RGB image. The pixel value should be within
%    [0.0, 1.0].
%
% Output:
%  * score: a numerical value representing the quality of the deblurring
%    result. Larger values mean higher quality.
%  * details: a struct that contains the feature values.


Example
=======
Please refer to example.m
