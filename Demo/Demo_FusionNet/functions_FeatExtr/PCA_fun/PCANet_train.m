function [f, V, BlkIdx, PCANet] = PCANet_train(InImg, PCANet, fidLogs, param, numCoresFeatExtr)
% =======INPUT=============
% InImg     Input images (cell); each cell can be either a matrix (Gray) or a 3D tensor (RGB)
% PCANet    PCANet parameters (struct)
%       .PCANet.NumStages
%           the number of stages in PCANet; e.g., 2
%       .PatchSize
%           the patch size (filter size) for square patches; e.g., [5 3]
%           means patch size equalt to 5 and 3 in the first stage and second stage, respectively
%       .NumFilters
%           the number of filters in each stage; e.g., [16 8] means 16 and
%           8 filters in the first stage and second stage, respectively
%       .HistBlockSize
%           the size of each block for local histogram; e.g., [10 10]
%       .BlkOverLapRatio
%           overlapped block region ratio; e.g., 0 means no overlapped
%           between blocks, and 0.3 means 30% of blocksize is overlapped
%       .Pyramid
%           spatial pyramid matching; e.g., [1 2 4], and [] if no Pyramid
%           is applied
% IdtExt    a number in {0,1}; 1 do feature extraction, and 0 otherwise
% =======OUTPUT============
% f         PCANet features (each column corresponds to feature of each image)
% V         learned PCA filter banks (cell)
% BlkIdx    index of local block from which the histogram is compuated
% =========================

% addpath('./Utils')

if length(PCANet.NumFilters)~= PCANet.NumStages
    fprintf_pers(fidLogs, 'Length(PCANet.NumFilters)~=PCANet.NumStages');
    return;
end %if length(PCANet.NumFilters)~= PCANet.NumStages

%init
NumImg = length(InImg);
V = cell(PCANet.NumStages, 1);
retainedVar = cell(PCANet.NumStages, 1);
NumFiltersInit = cell(PCANet.NumStages, 1);
OutImg = InImg;
ImgIdx = (1:NumImg)';
clear InImg;

for stage = 1 : PCANet.NumStages
    
    %display
    fprintf_pers(fidLogs, ['\t\tComputing PCA filter bank at stage ' num2str(stage) '...\n'])
    
    %compute PCANet filter
    [V{stage}, NumFiltersInit{stage}, retainedVar{stage}] = ...
        PCA_FilterBank(OutImg, PCANet.PatchSize(stage), PCANet.NumFilters(stage), stage, param, numCoresFeatExtr); % compute PCA filter banks
    
    %update number of filters
    PCANet.NumFilters(stage) = NumFiltersInit{stage};
    
    %display retained variance
    fprintf_pers(fidLogs, ['\t\t\tNum. of selected components: ' num2str(NumFiltersInit{stage}) '\n']);
    fprintf_pers(fidLogs, ['\t\t\tRetained variance (%%): ' num2str(retainedVar{stage}*100) '\n']);
    
    %compute the PCA outputs only when it is NOT the last stage
    fprintf_pers(fidLogs, ['\t\tComputing PCA outputs at stage ' num2str(stage) '...\n'])
    if stage ~= PCANet.NumStages
        [OutImg, ImgIdx] = PCA_output(OutImg, ImgIdx, ...
            PCANet.PatchSize(stage), PCANet.NumFilters(stage), V{stage});
    end %if stage ~= PCANet.NumStages
    
end %for stage = 1:PCANet.NumStages

%if we don't need wpca, extract features from only one sample
NumImg = 1;


%compute the PCANet training feature one by one
f = cell(NumImg, 1);

%display
fprintf_pers(fidLogs, '\t\tExtracting PCANet features of the training samples...\n');

%loop
for idx = 1 : NumImg
    
    %display progress
    if 0 == mod(idx, 20)
        fprintf_pers(fidLogs, ['\t\t\t' num2str(idx) '\n']);
    end %if mod
    
    %select feature maps corresponding to image "idx" (outputs of the-last-but-one PCA filter bank)
    OutImgIndex = (ImgIdx == idx);
    
    %compute the last PCA outputs of image "idx"
    [OutImg_i, ImgIdx_i] = PCA_output(OutImg(OutImgIndex), ones(sum(OutImgIndex),1), PCANet.PatchSize(end), PCANet.NumFilters(end), V{end});
    
    [f{idx}, BlkIdx] = HashingHist(PCANet, ImgIdx_i, OutImg_i); % compute the feature of image "idx"
    %[f{idx} BlkIdx] = SphereSum(PCANet,ImgIdx_i,OutImg_i); % Testing!!
    OutImg(OutImgIndex) = cell(sum(OutImgIndex),1);
    
end %for idx = 1:NumImg

%conversion to sparse for memory efficiency
f = sparse([f{:}]);

