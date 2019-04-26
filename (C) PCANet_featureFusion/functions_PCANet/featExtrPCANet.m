function [ftestPCA_all, filenameTestPCA] = ...
    featExtrPCANet(files, dirDB, V, PCANet, numFeatures, numImagesTest, allIndexes, indImagesTest, numCoresFeatExtr, stepPrint, param)


%init
ftestPCA_all = zeros(numFeatures, numImagesTest);
ftestPCA_all = sparse(ftestPCA_all);
%dobbiamo costruire un vettore incrementale per il parfor
vectorIndexTest = allIndexes(indImagesTest);
filenameTestPCA = cell(length(vectorIndexTest), 1);

%start pool
start_pool(numCoresFeatExtr);
parfor j = 1 : length(vectorIndexTest)
% for j = 1 : length(vectorIndexTest)
    
    %get id of current worker
    t = getCurrentTask();
    
    %read image
    filenameTestPCA{j} = files(vectorIndexTest(j)).name;
    imt = im2double(imread([dirDB filenameTestPCA{j}]));
    %resize based on largest dimension
    scale = max(size(imt)) / param.resizeSize;
    imt = imresize(imt, 1/scale);
    if size(imt, 3) == 3
        imt = rgb2gray(imt);
    end %if size
    im = {imt};
    
    %display progress
    if mod(j, stepPrint) == 0
        fprintf(1, ['\t\tCore ' num2str(t.ID) ': ' num2str(j) ' / ' num2str(numImagesTest) '\n'])
    end %if mod(i, 100) == 0
    
    %PCANet output
    ftestPCA = PCANet_FeaExt(im, V, PCANet);
    
    %save descriptor
    %w/out wpca
    ftestPCA_all(:, j) = ftestPCA;
    
end %parfor i = 1 : numImagesTest



