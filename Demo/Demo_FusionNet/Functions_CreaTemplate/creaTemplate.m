function [ftestNormAll, bg, img] = creaTemplate(cam, dirResults, dirModels, submodels, filename, dbname, param, plotta, savefile)


%--------------------------------------------------------------------------
%Acquisizione
returnCodeAcq = 0;
while returnCodeAcq == 0 || returnCodeAcq == -1
    [ROI, ROI_fingers, returnCodeAcq, bg, img] = acquisisciROI(cam, dirResults, filename, dbname, param, plotta, savefile);
end %while errorFinal

%mettiamo insieme
ROI_all = cell(5, 1);
for m = 1 : 4
    ROI_all{m} = ROI_fingers{m}; %fingers
end %for m
ROI_all{5} = ROI; %palm


%--------------------------------------------------------------------------
%Caricamento modelli
model = cell(5, 1);
for m = 1 : 5 %palm + 4 fingers
    %load model
    model{m} = load([dirModels submodels{m} '\PCANet_palm_iter_1.mat']);
end %for m
%calcolo num feat totale
numFeatTot = 0;
for m = 1 : 5 %palm + 4 fingers
    numFeatTot = numFeatTot + model{m}.numFeatures;
end %for m



%--------------------------------------------------------------------------
%Feature extraction
ftestNormAll = sparse(zeros(numFeatTot, 1));
count_ftest = 1;

for m = 1 : 5 %palm + 4 fingers
%for m = 5 %only palm
    
    %select ROI
    roi_selected = ROI_all{m};
    if size(roi_selected, 3) == 3
        roi_selected = rgb2gray(roi_selected);
    end %if size
    
    %process roi
    roi_selected = im2double(roi_selected);
    %resize based on largest dimension
    scale = max(size(roi_selected)) / param.resizeSize;
    roi_selected = imresize(roi_selected, 1/scale);
    
    %feat extr
    ftest = PCANet_FeaExt({roi_selected}, model{m}.V, model{m}.PCANet);
    
    %normalizzazione
    if strcmp(param.fusion.type, 'min-max')
        ftestNorm = normalizzaImg(ftest);
    end %if strcmp
    
    %normalizzazione
    if strcmp(param.fusion.type, 'none')
        ftestNorm = ftest;
    end %if strcmp
    
    %aggreg
    ftestNormAll(count_ftest : count_ftest + model{m}.numFeatures - 1, :) = ftestNorm;
    count_ftest = count_ftest + model{m}.numFeatures;
    
end %for m