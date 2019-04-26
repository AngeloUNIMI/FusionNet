function [imagesCellTrain, filenameTrnPCA] = loadImagesTraining(files, dirDB, allIndexes, indImagesTrain, numImagesTrain, param)

%init
vectorIndexTrain = allIndexes(indImagesTrain);
filenameTrnPCA = cell(length(vectorIndexTrain), 1);
imagesCellTrain = cell(numImagesTrain, 1);

%loop on training images
for i = 1 : length(vectorIndexTrain)
    
    %file
    filenameTrnPCA{i} = files(vectorIndexTrain(i)).name;
    im = im2double(imread([dirDB filenameTrnPCA{i}]));
    
    %resize based on largest dimension
    scale = max(size(im)) / param.resizeSize;
    im = imresize(im, 1/scale);
    
    %gray
    if size(im, 3) == 3
        imagesCellTrain{i, 1} = rgb2gray(im);
    else %if size
        imagesCellTrain{i, 1} = im;
    end %if size
    
end %for i = 1 : numImages