function [U, numFeaturesWpca] = computeWpca(ftrain, fileSaveWpca_iter, param)

if exist(fileSaveWpca_iter, 'file') ~= 2
    fprintf_pers(fidLogs, '\tWPCA computation... \n')
    %opts.tol = 1e-8;
    %opts.maxit = 150;
    %[U, D, ~] = lmsvd(ftrain, param.numFeatWPCA, opts); % Limited Memory Block Krylov
    [U, D, ~] = fsvd(ftrain, param.numFeatWPCA, 2, true); % fast but an approximation
    %[U, D, ~] = svds(ftrain, param.numFeatWPCA); % more accurate, but takes much long time
    U = U*diag(1./diag(D));
    %ftrain = U'*ftrain;
    ftrain_Wpca = U'*ftrain;
    %save
    if savefile
        save(fileSaveWpca_iter, 'U', 'ftrain_Wpca');
    end %if savefile
else %if exist(fileSaveWpca) ~= 2
    fprintf_pers(fidLogs, '\tLoading WPCA parameters... \n')
    load(fileSaveWpca_iter);
end %if exist(fileSaveWpca) ~= 2
%number of features
numFeaturesWpca = size(ftrain_Wpca, 1);