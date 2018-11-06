function f = feature_extract(imdist, scale)
    assert(size(imdist, 3) == 1);
    weight=[0.2 0.8];
    f = [];
    for i=1:scale

        im=imdist;
        fun0=@(x)secal(x);
        emat=blkproc(im,[8 8] ,fun0); 

        sort_t = sort(emat(:),'ascend');
        len = length(sort_t);
        t=sort_t(ceil(len*weight(1)):ceil(len*weight(2)));
        f1=[mean(t), skewness(sort_t)];

        im=imdist;
        fun1=@(x)fecal(x);
        im=double(im);
        femat=blkproc(im,[8 8],fun1);

        sort_t = sort(femat(:),'ascend');
        len = length(sort_t);
        t=sort_t(ceil(len*weight(1)):ceil(len*weight(2)));
        f2=[mean(t), skewness(sort_t)];

        f=[f, f1, f2] ;
        imdist = imresize(imdist,0.5);
    end
end

