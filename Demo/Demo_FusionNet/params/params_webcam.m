%PARAMS FOR
%webcam
%--------------------------------------

param.numSamp = 3;


%acquisition params
param.resFac = 3;
param.sizeSe = 1;

%segmentation params
param.segm.sizeShapeInterp = 3000;
param.segm.smoothShapeSize = 10; %100 for Savitsky-Golay / 50 for MA
param.segm.smoothShapeOrder = 2;

%peak finding params
param.peakFind.numIterCentroid = 1; %number of iterations to refine centroid (not working so well)
param.peakFind.smoothF = 150; %smoothing factor in searching peaks (valleys) from segmentations %100
param.peakFind.minPeakDistance = param.segm.sizeShapeInterp / 60; %50
param.peakFind.meanPksMult = 1.2;

%local search params
%THESE PROBABLY NEED TO BE TUNED FOR EACH DB
param.localsearch.beta = 20;
param.localsearch.alpha = 20;
param.localsearch.mu = 20;
%param.localsearch.localSearchOffset = round(param.peakFind.minPeakDistance / 5); %5
param.localsearch.offset = 300; %300 %molto alto
param.localsearch.maxDistance = 50; %questo delimita le aree di ricerca
param.localsearch.stepSearch = 5;
param.localsearch.stepAngle = 5;

%reject points params
param.rejectPoints.thAngle = 35; %30
param.rejectPoints.thDiffAngle = 10;
param.rejectPoints.percBlackPixels = 0.05; %0.05
param.rejectPoints.percCheckExtArea = 0.3;
param.rejectPoints.numStepsCheckExtArea = 10;
param.rejectPoints.minDistanceBorder = 5;

%roi size params
%use these to refine grad
param.ROIsize.useRefineGrad = 1;
param.ROIsize.sizeROI = [300 300]; %empirical based on papers (128-150)
param.ROIsize.multX = 1.4;
param.ROIsize.multY = 1 + 2/5;
param.ROIsize.multOffset = 1/5; %es. 1/5 of distance between valleys
param.ROIsize.percBlackPixels = 0.30;

%params toi fingers
param.roifing.factDist = 2;
param.roifing.numFingers = 4;
%finger size
param.roifing.sizeROI = [80 300];

%params resize
param.resizeSize = 150; %largest dimension

%parametri fusion
param.fusion.type = 'min-max'; %'none'


