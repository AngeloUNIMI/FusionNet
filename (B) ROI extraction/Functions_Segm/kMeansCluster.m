function [binar, pixel_labels] = kMeansCluster(input_image, param)

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

% figure,
% imshow(pixel_labels,[])
% pause

%get area at the center
valCent = pixel_labels(round(size(pixel_labels,1)/2), round(size(pixel_labels,2)/2));
binar = (pixel_labels == valCent);