function [ftestPCA_all, ftestPCA_Wpca_all, distMatrix, distMatrixBestRot, filenameTestPCA] = ...
    featExtrPCANet_and_matchingRot(files, dirDB, V, PCANet, U, numFeatures, numFeaturesWpca, numImagesTest, allIndexes, indImagesTest, ...
    numCoresFeatExtr, ext, stepPrint, plotta, log, param)


%start pool
start_pool(numCoresFeatExtr);

%EXTERNAL LOOP
%init
ftestPCA_all = zeros(numFeatures, numImagesTest);
ftestPCA_all = sparse(ftestPCA_all);
ftestPCA_Wpca_all = zeros(numFeaturesWpca, numImagesTest);
ftestPCA_Wpca_all = sparse(ftestPCA_Wpca_all);
wpcaParallel = param.wpca;
vectorIndexTest = allIndexes(indImagesTest);
filenameTestPCA = cell(length(vectorIndexTest), 1);
distMatrixBestRot = -1 .* ones(numImagesTest, numImagesTest);
%loop
parfor j = 1 : length(vectorIndexTest)
% for j = 1 : length(vectorIndexTest)
    
    %get id of current worker
    t = getCurrentTask();
    
    %display progress
    if mod(j, stepPrint) == 0 && log
        fprintf(1, ['\t\tCore ' num2str(t.ID) ' - Sample 1: ' num2str(j) '/' num2str(numImagesTest) '\n'])
%         fprintf(1, ['\t\tSample 1: ' num2str(j) '/' num2str(numImagesTest) '\n'])
    end %if mod(i, 100) == 0
    
    %read image
    filenameTestPCA{j} = files(vectorIndexTest(j)).name;
    im = {im2double(imread([dirDB filenameTestPCA{j}]))};
    if size(im, 3) == 3
        im = rgb2gray(im);
    end %if size
    
    %PCANet output
    ftestPCA_1 = PCANet_FeaExt(im, V, PCANet);
    %data structure all features
    ftestPCA_all(:, j) = ftestPCA_1;
    
    %WPCA
    if wpcaParallel
        ftest_Wpca_1 = U' * ftestPCA_1;
        ftestPCA_Wpca_all(:, j) = ftest_Wpca_1;
    end %if wpca
    
    %INNER LOOP
    %init
    distVectorInner = zeros(1, numImagesTest); %init with big number since we must extract the minimum
    for k = j + 1 : length(vectorIndexTest) %start from j + 1, matching is symmetric
        
        %skip same sample
        if j == k
            continue
        end %if j == k
        
        %display
        if mod(k, stepPrint) == 0 && plotta && log
            fprintf(1, ['\t\t\tSample 1: ' num2str(j) '/' num2str(numImagesTest) ' - ']);
            fprintf(1, ['Sample 2: ' num2str(k) '/' num2str(numImagesTest) '\n']);
        end %if log
        
        %read image
        filename2 = files(vectorIndexTest(k)).name;
        
        %look for rotated files
        [C, ~] = strsplit(filename2, '.');
        files_rot = dir([dirDB '/rotated/' C{1} '_r*.' ext]);
        numRots = numel(files_rot);
        
        %loop on rotated files
        %init
        ftestPCA_2_rot_all = zeros(numFeatures, length(param.rotationsAllowed));
        ftestPCA_2_rot_all = sparse(ftestPCA_2_rot_all);
        countRot = 1;
        for rots = 1 : numRots
            
            %rotated image filename
            filenameRot = files_rot(rots).name;
            C = strsplit(filenameRot, {'r', '.'});
            rotStr = C{2};
            
            %if rotations is not present, skip
            if numel(strfind(num2str(param.rotationsAllowed), rotStr)) == 0
                continue
            end %if numel
            
            %display
            if mod(k, stepPrint) == 0 && plotta && log
                fprintf(1, ['\t\t\t\tRotation: ' rotStr '\n'])
            end %if log
            
            %read image
            im = {im2double(imread([dirDB '/rotated/' filenameRot]))};
            
            %PCANet output
            ftestPCA_2_rot = PCANet_FeaExt(im, V, PCANet);
            ftestPCA_2_rot_all(:, countRot) = ftestPCA_2_rot;
            
            %WPCA
            if wpcaParallel
                ftest_Wpca_2 = U' * ftestPCA_2;
            end %if wpca
            
            %increment rotation counter
            countRot = countRot + 1;
            
        end %for r
        
%         j, k
%         ftestPCA_1(1:100), 
%         ftestPCA_2_rot_all(1:100, 1)
%         pause
        
        
        %compute distance (match score)
        if strcmp(param.matchDistance, 'euclidean')
            %fast Euclidean distance
            distRot = full(fastEuclideanDistance(ftestPCA_1, ftestPCA_2_rot_all));
        else %if strcmp
            distRot = pdist2(ftestPCA_1', ftestPCA_2_rot_all', param.matchDistance);
        end %if strcmp
        
        %update distance matrix
        [minDistRot, indMinDistRot] = min(distRot);
        distVectorInner(k) = minDistRot;
        %display
        if mod(k, stepPrint) == 0 && plotta && log
            fprintf(1, ['\t\t\t\tBest rotation: ' num2str(indMinDistRot) ' (' num2str(param.rotationsAllowed(indMinDistRot)) ' deg)\n']);
        end %if log
        
%         minDistRot
%         pause
        
    end %for k - internal loop
    
    %update distance matrix
    distMatrixBestRot(j, :) = distVectorInner;
    
%     pause
    
end %for j - external loop


%distance matrix standard
if strcmp(param.matchDistance, 'euclidean')
    %fast Euclidean distance
    distMatrix = full(fastEuclideanDistance(ftestPCA_all, ftestPCA_all));
else %if strcmp
    distMatrix = pdist2(ftestPCA_all', ftestPCA_all', param.matchDistance);
end %if strcmp




% distMatrix
% distMatrixBestRot,
% pause






