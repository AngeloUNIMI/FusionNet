function [ftrain, numFeatures, V, PCANet] = trainPCANet(imagesCellTrain, PCANet, fidLogs, param, numCoresFeatExtr)

%PCANet training
fprintf_pers(fidLogs, '\tPCANet training... \n')
tic
[ftrain, V, ~, PCANet] = PCANet_train(imagesCellTrain, PCANet, fidLogs, param, numCoresFeatExtr);

%time for training
PCANet_TrnTime = toc;
fprintf_pers(fidLogs, ['\t\tTime for PCANet training: ' num2str(PCANet_TrnTime) ' s\n']);


%number of features
numFeatures = size(ftrain, 1);

