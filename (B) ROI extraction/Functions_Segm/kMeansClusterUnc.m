function [binar, pixel_labels] = kMeansClusterUnc(input_image, param)

%init
input_image_double = im2double(input_image);

%skin color th
maskSkinColor = skinColorTh(input_image);

%lab color space
lab_he = rgb2lab(input_image);

ab = lab_he(:,:,2:3);
ab = im2single(ab);
% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab, param.segm.nKMeansColors, 'NumAttempts', param.segm.numkMeansAttempts);

figure,
imshow(pixel_labels,[])
pause

%get color with most pixels
numColors = max(unique(pixel_labels(:)));
numCV = zeros(numColors, 1);
parfor i = 1 : numColors
    binar = (pixel_labels == i);
    maskColorTh = binar .* maskSkinColor;
    
%     figure,
%     subplot(1,3,1)
%     imshow(binar)
%     subplot(1,3,2)
%     imshow(maskColorTh)
%     subplot(1,3,3)
%     imshow(input_image_double .* maskColorTh)
    
    numC = numel(find(maskColorTh));
    numCV(i) = numC;
end %for i

%select color
[~, isort] = sort(numCV, 'descend');
binar = (pixel_labels == isort(1));