
%------------------------------
%General parameters
param.numIterations = 5; %number of re-iterations.
% param.numIterations = 1; %number of re-iterations.
param.kfold = 2; %k-1 partition used for training; 1 partitions for testing
%knn parameters
param.knn_neighbors = 1;
param.matchDistance = 'euclidean';
param.knnDistance = 'euclidean';
%param.matchDistance = 'chisq';
%param.knnDistance = 'chisq';
param.numScoreAggregate = 4; %anche 4 usato in paper recenti
param.useDynamicNumFilters = 0;
param.RetainedVariance = [0.89 0.94];

%------------------------------
param.resizeSize = 150; %largest dimension

%------------------------------
%PCANet parameters
PCANet.NumStages = 2; %2
PCANet.PatchSize = [15 15]; %(default  [5 5]) ([15 15] seems good for iitd)
PCANet.NumFilters = [10 10]; % (default [8 8]) ([10 10] seems good for iitd)
PCANet.HistBlockSize = [23 23]; %(default 15 15) ([23 23] seems good for iitd)
PCANet.BlkOverLapRatio = 0;
PCANet.Pyramid = [];

%------------------------------
%Rotation parameters
%param.rotationsAllowed = [-15, -10, -5, 0, 5, 10, 15];
% param.rotationsAllowed = [-9, -6, -3, 0, 3, 6, 9];
% Q. Zheng, A. Kumar and G. Pan,
% "A 3D Feature Descriptor Recovered from a Single 2D Palmprint Image,"
% in IEEE Transactions on Pattern Analysis and Machine Intelligence, 
% vol. 38, no. 6, pp. 1272-1279, June 1 2016.
param.rotationsAllowed = 0;

%------------------------------
%CRCompCode CRC_RLS parameters
param.useCRC_RLS = false;
param.lambda = 1.35; %a parameter used in solving CRC_RLS

%------------------------------
%parametri fusion
param.fusion.type = 'min-max'; %'none'


