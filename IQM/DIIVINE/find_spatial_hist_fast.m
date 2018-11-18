function [b, rho, ypred, matrix, xval] = find_spatial_hist_fast(orig_img)
    % Function to find the spatial histogram for IMAGE and then compute Corr
    % and fit 3-parameter logistic. returns logistic fitting value.
    [nrows, ncols] = size(orig_img);
    nbins = 100;
    max_x = 25;
    ss_fact = 4;
    [~, bins] = hist(orig_img(:), nbins);
    assert(issorted(bins));
    x = reshape(interp1(bins, bins, orig_img(:), 'nearest', 'extrap'), nrows, ncols);
    rho = zeros(1, 1+floor((max_x-1)/ss_fact));
    for j = 1:ss_fact:max_x
        matrix = zeros(nbins);
        parfor i = 1:nbins
            [r, c] = find(x==bins(i));
            if ~isempty(r)
                h = zeros(1, nbins);
                %%
                ctemp = c-j;
                rtemp = r;
                rtemp(ctemp<1) = [];
                ctemp(ctemp<1) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                ctemp = c+j;
                rtemp = r;
                rtemp(ctemp>ncols) = [];
                ctemp(ctemp>ncols) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                rtemp = r-j;
                ctemp = c;
                ctemp(rtemp<1) = [];
                rtemp(rtemp<1) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                rtemp = r+j;
                ctemp = c;
                ctemp(rtemp>nrows) = [];
                rtemp(rtemp>nrows) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                rtemp = r+j;
                ctemp = c;
                ctemp(rtemp>nrows) = [];
                rtemp(rtemp>nrows) = [];
                ctemp = ctemp+j;
                rtemp(ctemp>ncols) = [];
                ctemp(ctemp>ncols) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                rtemp = r+j;
                ctemp = c;
                ctemp(rtemp>nrows) = [];
                rtemp(rtemp>nrows) = [];
                ctemp = ctemp-j;
                rtemp(ctemp<1) = [];
                ctemp(ctemp<1) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                rtemp = r-j;
                ctemp = c;
                ctemp(rtemp<1) = [];
                rtemp(rtemp<1) = [];
                ctemp = ctemp+j;
                rtemp(ctemp>ncols) = [];
                ctemp(ctemp>ncols) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                rtemp = r-j;
                ctemp = c;
                ctemp(rtemp<1) = [];
                rtemp(rtemp<1) = [];
                ctemp = ctemp-j;
                rtemp(ctemp<1) = [];
                ctemp(ctemp<1) = [];
                ind = sub2ind(size(orig_img),rtemp,ctemp);
                if ~isempty(ind)
                    h = h+hist(orig_img(ind),bins);
                end
                %%
                matrix(i,:) = h;
            end

        end
        X = bins';
        Y = X;
        matrix = matrix/sum(sum(matrix));
        px = sum(matrix,2);
        py = sum(matrix,1)';
        mu_x = sum(X.*px);
        mu_y = sum(Y.*py);
        sigma2_x = sum((X-mu_x).^2.*px);
        sigma2_y = sum((Y-mu_x).^2.*py);
        [xx, yy] = meshgrid(X,Y);
        rho((j-1)/ss_fact+1) = (sum(sum(xx.*yy.*matrix))-mu_x.*mu_y)/(sqrt(sigma2_x)*sqrt(sigma2_y));
    end
    xval = 1:ss_fact:max_x;
    pp = polyfit(xval,rho,3);
    ypred = polyval(pp,xval);
    err = sum((ypred-rho).^2);
    b = [pp err];
    %% figure
    % plot(rho,'r','LineWidth',3); hold on
    % plot(ypred,'k'); title(['Error:',num2str( sum((ypred-rho).^2))]);
    % toc
    % subplot(1,3,1)
    % imagesc(log(matrix+1));colormap(gray);axis xy
    % subplot(1,3,2)
    % bar(bins,sum(matrix,1)); axis([1 255 0 max(sum(matrix,1))])
    % subplot(1,3,3)
    % bar(bins,sum(matrix,2));axis([1 255 0 max(sum(matrix,2))])
end
