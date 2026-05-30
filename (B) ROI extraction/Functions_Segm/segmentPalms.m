function [shapeFinal, centroid, bw_e_smooth] = segmentPalms(input_image, param, dbname, filename, jpgFiles, savefile, plotta)


%----------------------
%output: image without modifications
input_image_original = input_image;

%----------------------
%convert
input_image = convertImageSingleChannel(input_image_original, param.segm.colorSpaceTrans); 

%----------------------
%resize
input_image = imresize(input_image, param.segm.resizeF);
input_image_color = imresize(input_image_original, param.segm.resizeF);



%----------------------
%enhance
input_image = imadjust(input_image, stretchlim(input_image, [0.01 0.99]));
%input_image_color = imadjust(input_image_color, stretchlim(input_image_color, [0.01 0.99]));

%----------------------
%normalize
if param.segm.normalizza == 1
    input_image = normalizzaImg(input_image);
    input_image_color = normalizzaImg(input_image_color);
end %if param.normalizza = 1


%----------------------
%gaussian smoothing filter
C = filterGauss(input_image, param.segm.fGauss_size, param.segm.fGauss_sigma);
C_uint8 = im2uint8(C);
C_color = filterGauss(input_image_color, param.segm.fGauss_size, param.segm.fGauss_sigma);

%----------------------
%threshold
% binar = skinColorTh(C_color);
if strcmp(dbname, 'NUIG_Palmprint_Database_background_unconstrained') == 1
    [binar, pixel_labels] = kMeansClusterUnc(C_color, param);
end %if strcmp
if strcmp(dbname, 'NUIG_Palmprint_Database_background_wood') == 1
    [binar, pixel_labels] = kMeansCluster(C_color, param);
end %if strcmp
if strcmp(dbname, 'REST_hand_database') == 1
    binar = thresholdPalm(C, param);
    pixel_labels = [];
end %if strcmp

% %display
% figure, 
% subplot(1,3,1) 
% imshow(input_image_original), 
% subplot(1,3,2) 
% imshow(binar), 
% subplot(1,3,3)
% imshow(pixel_labels,[])
% pause

%----------------------
%fill
binar = imfill(binar, 'holes');
binar = bigConnComp(binar, 1);

%----------------------
%morph
binar = imclose(binar, strel(param.segm.typeStrel, param.segm.sizeStrel_small));
binar = imclose(binar, strel(param.segm.typeStrel, param.segm.sizeStrel_small));

% imshow(binar)
% pause

%----------------------
%first edge to add
vess = VesselExtract(C_uint8, 0);
[vess, minVess, maxVess] = normalizzaImg(vess);
vess2 = zeroBorder(vess);
% vess2 = vess;
[thVessF, ~] = graythresh(vess2);
edge_added = vess2 > thVessF;

%morph
edge_added = imclose(edge_added, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
edge_added = imopen(edge_added, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));

%add to image
if param.segm.useEdgeAdd
    binar_plus_edge = binar + edge_added;
    binar_plus_edge(binar_plus_edge~=0) = 1;
    binar_plus_edge = logical(binar_plus_edge);
    %morph
    binar_plus_edge = imclose(binar_plus_edge, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
    binar_plus_edge = imfill(binar_plus_edge, 'holes');
    binar_plus_edge = imopen(binar_plus_edge, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
else %if param.segm.useEdgeAdd
    binar_plus_edge = binar;
end %if param.segm.useEdgeAdd
%select bigger cc and fill
binar_plus_edge = bigConnComp(binar_plus_edge, 1);

%----------------------
%look for orientation that gives minimum ratio
%between horizontal edges and vertical edges
%then we keep the horizontal edges image
%compute horizontal and vertical edges so we have the orientation approx
%vertical edges: borders of fingers
[edgeM_ho, edgeM_ve, orientM] = findOrientBasedonEdge(C, C_uint8, thVessF, param);
% orientM
%apply normalization based on global vess
edgeM_ho = rescaleImg(edgeM_ho, minVess, maxVess);
edgeM_ve = rescaleImg(edgeM_ve, minVess, maxVess);
%thresholding
%vertical
thVessVe = thVessF + param.segm.thVessModVe;
edge_removed_orig = edgeM_ve > thVessVe; %rendiamo morbida la soglia per gli edge verticali
%horizontal
thVessHo = thVessF + param.segm.thVessModHo;
refl_orig = edgeM_ho > thVessHo;
    
%----------------------
%vertical edges: edges to remove
orientLineStrel = 90 - orientM;
if param.segm.subEdgesVer
    
    %init
    edge_removed = edge_removed_orig;
    
    %subtract horizontal image
    edge_removed = edge_removed - refl_orig;
    %edge_removed = edge_removed - imerode(refl_orig, strel(param.segm.typeStrel, param.segm.sizeStrel_small));
    edge_removed(edge_removed~=1) = 0;
    
    edge_removed = imdilate(edge_removed, strel(param.segm.typeStrelEdge, param.segm.sizeStrelEdge_small, orientLineStrel));
    edge_removed = imclose(edge_removed, strel(param.segm.typeStrelEdge, param.segm.sizeStrelEdge_huge, orientLineStrel));
    edge_removed = imopen(edge_removed, strel(param.segm.typeStrelEdge, param.segm.sizeStrelEdge_medium, orientLineStrel));
    %edge_removed = imopen(edge_removed, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
    %remove cc with area less than 300
    edge_removed = removeCCArea(edge_removed, param.segm.thArea);
    
    %subtract from original image
    binar_minus_edge = binar_plus_edge - edge_removed;
    binar_minus_edge(binar_minus_edge~=1) = 0;
    binar_minus_edge = logical(binar_minus_edge);
    
    %morph
    binar_minus_edge = imopen(binar_minus_edge, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
    %binar_minus_edge = imclose(binar_minus_edge, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
else %if param.segm.subEdgesVer
    edge_removed = edge_removed_orig;
    binar_minus_edge = binar_plus_edge;
end %if param.segm.subEdgesVer


% binar_minus_edge = filterGauss(double(binar_minus_edge), param.segm.fGauss_size, param.segm.fGauss_sigma);
% binar_minus_edge = binar_minus_edge > 0.5;


%----------------------
%horizontal edges: reflections or palm lines
if param.segm.useRefl
    
    %init
    refl = refl_orig;
    
    %subtract vert image
    refl = refl - edge_removed_orig;
    refl(refl~=1) = 0;
    
    %morph refl image
    refl = imdilate(refl, strel(param.segm.typeStrelEdge, param.segm.sizeStrelEdge_small, orientLineStrel-90));
    refl = imclose(refl, strel(param.segm.typeStrelEdge, param.segm.sizeStrelEdge_large, orientLineStrel-90));
    %refl = imopen(refl, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
    
%     figure,
%     imshow(refl,[])
%     pause

    binar_plus_refl = binar_minus_edge + refl;
    binar_plus_refl(binar_plus_refl~=0) = 1;
    binar_plus_refl = logical(binar_plus_refl);
    %fill
    binar_plus_refl = imfill(binar_plus_refl, 'holes');
    
    %morph image after adding reflections
    binar_plus_refl = imopen(binar_plus_refl, strel(param.segm.typeStrel, param.segm.sizeStrel_large));
    %binar_plus_refl = imclose(binar_plus_refl, strel(param.segm.typeStrel, param.segm.sizeStrel_medium));
else %if param.segm.useRefl
    refl = refl_orig;
    binar_plus_refl = binar_minus_edge;
end %%if param.segm.useRefl

%----------------------
%select bigger cc and fill
binar_plus_refl = bigConnComp(binar_plus_refl, 1);

%----------------------
%invert resize
binar_plus_refl = imresize(binar_plus_refl, 1/param.segm.resizeF);
input_image = imresize(input_image, 1/param.segm.resizeF);
input_image_color = imresize(input_image_color, 1/param.segm.resizeF);

% whos binar_plus_refl input_image input_image_color


%----------------------
%Detect the Boundary
[B, ~, ~] = bwboundaries(binar_plus_refl);
%The bwboundaries function implements the Moore-Neighbor tracing algorithm
%modified by Jacob's stopping criteria. This function is based on the
%boundaries function presented in the first edition of Digital Image
%Processing Using MATLAB, by Gonzalez, R. C., R. E. Woods, and S. L. Eddins,
%New Jersey, Pearson Prentice Hall, 2004.

%----------------------
%centroid
centroid = regionprops(binar_plus_refl, 'Centroid');
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
    
    %whos input_image binar
    
    fh = figure(1);
        
    subplot(1,2,1)
    imshow(input_image_color,[])
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
    
    mtit(fh, [dbname ' - ' filename], 'Interpreter', 'none', 'fontsize', 20, 'color', [1 0 0], 'xoff', .0, 'yoff', .04);
    legend('Final segmentation', 'Location', 'southeast');
    
    fh.WindowState = 'maximized';
    set(gcf, 'color', 'white');
    
    if savefile
        C = strsplit(filename, '.');
        export_fig([jpgFiles C{1} '_Segm.jpg'], '-q50');
    end %if savefile
    
    %pause
    
end %if plotta

% figure,
% imshow(bw_e_smooth, []);
% hold on;
% plot(shapeFinal(:,1), shapeFinal(:,2), 'r--', 'LineWidth', 2, 'MarkerSize', 11);
% pause



