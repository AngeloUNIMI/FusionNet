function [fingers, rotROI_fingers, errorF] = extractFingers(rotPalm, rotBw, top1, top2, bottom1, bottom2, grad, gradRefined, param, dbname, filename, jpgFiles, savefile, plotta)

%init
errorF = 0;
fingers = [];
rotROI_fingers = [];

top1 = round(top1(1));
top2 = round(top2(1));
bottom1 = round(bottom1(1));
bottom2 = round(bottom2(1));

% figure
% imshow(rotBw)
% hold on
% plot(top1, top2, 'r*', 'LineWidth', 2, 'MarkerSize', 10)
% plot(bottom1, bottom2, 'g*', 'LineWidth', 2, 'MarkerSize', 10)

%distance between valleys
distY_valleys = abs(top2 - bottom2);

%extract finger region
bwFingers = zeros(size(rotBw));

%check limis
if (top2 - round(distY_valleys)) < 1 || (bottom2 + round(distY_valleys)) > size(bwFingers, 1) || (top1 - round(distY_valleys/param.roifing.factDist)) < 1
    errorF = -1;
    return;
else %if
    bwFingers(top2 - round(distY_valleys) : bottom2 + round(distY_valleys), 1 : top1 - round(distY_valleys/param.roifing.factDist)) = ...
        rotBw(top2 - round(distY_valleys) : bottom2 + round(distY_valleys), 1 : top1 - round(distY_valleys/param.roifing.factDist));
end %if

% figure
% imshow(bwFingers)
% hold on
% plot(top1, top2, 'r*', 'LineWidth', 2, 'MarkerSize', 10)
% plot(bottom1, bottom2, 'g*', 'LineWidth', 2, 'MarkerSize', 10)

%error
%bw label
rotBwLabel = -90;
bwFingersRot = imrotate(bwFingers, rotBwLabel);
labels = bwlabel(bwFingersRot);

if max(labels(:)) < param.roifing.numFingers
    errorF = -1;
    return;
elseif max(labels(:)) > param.roifing.numFingers %if max
    %sono di più, prendo i 4 più grandi
    bwFingersRot = getLargestCc(logical(bwFingersRot), 4, param.roifing.numFingers);
    labels = bwlabel(bwFingersRot);
end %if max

%extract single fingers
ROI_fingers = cell(param.roifing.numFingers, 1);
parfor f = 1 : param.roifing.numFingers
    ROI_fingers{f} = imrotate((labels == f), -rotBwLabel);
end %for f

%rotate the rois separately and extract fingers
%init
fingers = cell(param.roifing.numFingers, 1);
orient = cell(param.roifing.numFingers, 1);
rotROI_fingers = cell(param.roifing.numFingers, 1);
%parfor f = 1 : param.roifing.numFingers
for f = 1 : param.roifing.numFingers
    
    %select finger ROI
    ROI_singleFinger = ROI_fingers{f};
    
    %imshow(ROI_singleFinger)
   
    %compute orientation
    stats = regionprops(ROI_singleFinger, 'Orientation');
    if numel(stats) == 0
        errorF = -1;
        return;
    end %if numel
    orient{f} = stats.Orientation;
    
    %rotation matrix
    rotM = [cosd(orient{f}) -sind(orient{f}); sind(orient{f}) cosd(orient{f})];
    
    %center of rotation is center of image
    centerRot = [size(rotPalm,2)/2; size(rotPalm,1)/2];
    
    %rotate finger roi
    rotRoiFinger = imrotate(ROI_singleFinger, -orient{f}, 'crop');
    %rotate palm image
    rotPalmAccordingToFinger = imrotate(rotPalm, -orient{f}, 'crop');
    %rotate full roi
    rotRoiBwFullAccordingToFinger = imrotate(rotBw, -orient{f}, 'crop');
    %rotate valley points
    topMinCenter = [top1; top2] - centerRot;
    topRot = (rotM * topMinCenter) + centerRot;
    bottomMinCenter = [bottom1; bottom2] - centerRot;
    bottomRot = (rotM * bottomMinCenter) + centerRot;
    
    %extend finger ROI
    %max x coord
    minxX = min([topRot(1), bottomRot(1)]);
    [yy, xx] = find(rotRoiFinger);
    rotRoiFinger(min(yy) : max(yy), min(xx) : round(minxX)) = rotRoiBwFullAccordingToFinger(min(yy) : max(yy), min(xx) : round(minxX));
    
    %extract finger
    [yyRoiFinger, xxRoiFinger] = find(rotRoiFinger);
    rotPalmAccordingToFingerMasked = im2double(rotPalmAccordingToFinger) .* rotRoiBwFullAccordingToFinger;
    fingerExtracted = rotPalmAccordingToFingerMasked(min(yyRoiFinger) : max(yyRoiFinger), min(xxRoiFinger) : max(xxRoiFinger), :);
    
    %resize
    fingerExtractedRes = imresize(fingerExtracted, param.roifing.sizeROI, 'bicubic');
    
    %assign to structure
    fingers{f} = fingerExtractedRes;
    rotROI_fingers{f} = rotRoiFinger;
    
end %for f


%display

if plotta
    
    %init
    posText = cell(param.roifing.numFingers, 1);
    
    %compensate original rotation
    if gradRefined
        grad = grad + 180;
    end %if gradrefined
    palmOrig = imrotate(rotPalm, grad);
    
    %find start of color
    [ycol, xcol] = find(rgb2gray(palmOrig));
    palmOrig2 = palmOrig(min(ycol) : max(ycol), min(xcol) : max(xcol), :);
  
    PalmVis = im2double(palmOrig2);
    for f = 1 : param.roifing.numFingers
        tt = imrotate(ROI_fingers{f}, grad);
        ROI_fingerOrig = tt(min(ycol) : max(ycol), min(xcol) : max(xcol));
        [irfo, jrfo] = find(ROI_fingerOrig);
        posText{f} = [mean(jrfo), mean(irfo)];
        PalmVis = PalmVis + edge(ROI_fingerOrig);
    end %for f
    
    extra = 3;
    
    fh = figure(3);
    subplot(1,param.roifing.numFingers+extra,[1:extra])
    imshow(PalmVis);
    hold on
    for f = 1 : param.roifing.numFingers
        posTextF = posText{f};
        text(posTextF(1), posTextF(2), num2str(f), 'FontSize', 20);
    end %for f
    title('Palm and preliminary finger ROIs');
    hold off
    
    for f = 1 : param.roifing.numFingers
        subplot(1,param.roifing.numFingers+extra,extra+f)
        imshow(imrotate(fingers{f}, -90));
        title(['Finger n. ' num2str(f)]);
    end %for f
    
    fh.WindowState = 'maximized';
    
    mtit(fh, [dbname ' - ' filename], 'Interpreter', 'none', 'fontsize', 20, 'color', [1 0 0], 'xoff', .0, 'yoff', .04);
    
    set(gcf, 'color', 'white');
    
    if savefile
        C = strsplit(filename, '.');
        export_fig([jpgFiles dbname '_' C{1} '_Fingers.jpg'], '-q50');
    end %if savefile
    
end %if plotta
    
%     figure
%     subplot(2,2,1)
%     imshow(im2double(rotPalm) + edge(ROI_singleFinger))
%     hold on
%     plot(top1, top2, 'r*', 'LineWidth', 2, 'MarkerSize', 10)
%     plot(bottom1, bottom2, 'g*', 'LineWidth', 2, 'MarkerSize', 10)
% 
%     subplot(2,2,2)
%     imshow(im2double(rotPalmAccordingToFinger) + edge(rotRoiFinger))
%     hold on
%     plot(topRot(1), topRot(2), 'r*', 'LineWidth', 2, 'MarkerSize', 10)
%     plot(bottomRot(1), bottomRot(2), 'g*', 'LineWidth', 2, 'MarkerSize', 10)
% 
% 
%     subplot(2,2,3)
%     imshow(im2double(rotPalmAccordingToFinger) + edge(rotRoiFinger))
%     hold on
%     plot(topRot(1), topRot(2), 'r*', 'LineWidth', 2, 'MarkerSize', 10)
%     plot(bottomRot(1), bottomRot(2), 'g*', 'LineWidth', 2, 'MarkerSize', 10)
% 
% 
%     subplot(2,2,4)
%     imshow(fingerExtracted)


