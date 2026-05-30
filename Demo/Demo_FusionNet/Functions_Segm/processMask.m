function [shapeFinal, centroid, bw_e_smooth] = processMask(maskRaw, input_image, dirResults, filename, param, plotta, savefile)

se = strel('disk', param.sizeSe);
mask = imclose(imopen(maskRaw, se), se);

mask = bigConnComp(mask, 1);

%Detect the Boundary
[B, ~, ~] = bwboundaries(mask);
%The bwboundaries function implements the Moore-Neighbor tracing algorithm
%modified by Jacob's stopping criteria. This function is based on the
%boundaries function presented in the first edition of Digital Image
%Processing Using MATLAB, by Gonzalez, R. C., R. E. Woods, and S. L. Eddins,
%New Jersey, Pearson Prentice Hall, 2004.

%----------------------
%centroid
centroid = regionprops(mask, 'Centroid');
centroid = centroid(1).Centroid;

%This is the edge we are interested in
outline = flipud(B{1});

%x,y coord
shapeFinal(:,1) = outline(:,2);
shapeFinal(:,2) = outline(:,1);


%----------------------
%interpolate shape to common size
shapeFinal = resizem(shapeFinal, [param.segm.sizeShapeInterp 2], 'bilinear');

%----------------------
%Smoothing
windowWidth = roundOdd(param.segm.smoothShapeSize); %11
% shapeFinal(:,1) = sgolayfilt(shapeFinal(:,1), param.segm.smoothShapeOrder, windowWidth);
% shapeFinal(:,2) = sgolayfilt(shapeFinal(:,2), param.segm.smoothShapeOrder, windowWidth);
shapeFinal(:,1) = smooth(shapeFinal(:,1), windowWidth);
shapeFinal(:,2) = smooth(shapeFinal(:,2), windowWidth);


%----------------------
%binary mask from smoother border
bw_e_smooth = poly2mask(shapeFinal(:, 1), shapeFinal(:, 2), size(input_image,1), size(input_image,2));


%----------------------
%plot
if plotta
    
    fh = figure;
    fh.WindowState = 'maximized';
    
    subplot(1,2,1)
    imshow(input_image,[])
    title('Original Image')
    hold on
    plot(shapeFinal(:,1), shapeFinal(:,2), 'r--', 'LineWidth', 2, 'MarkerSize', 11);
    hold off
    
    subplot(1,2,2)
    imshow(bw_e_smooth,[])
    title('Final segmentation')
    hold on
    plot(shapeFinal(:,1), shapeFinal(:,2), 'r--', 'LineWidth', 2, 'MarkerSize', 11);
    hold off
    
    if savefile
        C = strsplit(filename, '.');
        export_fig([dirResults C{1} '_Segm.jpg'], '-q50');
    end %if savefile
    
end %if plotta