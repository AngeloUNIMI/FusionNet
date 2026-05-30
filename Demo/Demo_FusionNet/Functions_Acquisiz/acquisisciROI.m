function [ROI, ROI_fingers, returnCodeAcq, bg, img] = acquisisciROI(cam, dirResults, filename, dbname, param, plotta, savefile)


%--------------------------------------------------------------------------
h1 = figure(1);
set(gcf,'CurrentCharacter','@');
stop = 0;
%get background
while ~stop
    
    img = snapshot(cam);
    
    %figure(1)
    imshow(imresize(fliplr(img), param.resFac))
    title('Press -s- to capture the background, WITHOUT BODY PARTS');
    
    pause(0.1);
    
    button = get(gcf,'CurrentCharacter');
    switch button
        case 113 %q
            %stop = 1;
            %set(gcf,'CurrentCharacter','@');
        case 115 %s
            %bg = snapshot(cam);
            bg = img;
            bgProc = processSkin(bg);
            stop = 1;
            set(gcf,'CurrentCharacter','@');
    end
    
end %while ~stop


%--------------------------------------------------------------------------
figure(1)
stop = 0;
%diff image
while ~stop
    
    img = snapshot(cam);
    img2 = abs(processSkin(img) - bgProc);
    img2_bin = img2 > graythresh(img2) * 255;
    
    %size
    sizeIm = size(img);
    
    %figure, imshow(img2_bin)
    
    %figure(1)
    subplot(1,2,1)
    imshow(imresize(fliplr(img), param.resFac))
    %imshow(img)
    hold on
    rectangle('Position', [round(sizeIm(2)/10)*param.resFac round(sizeIm(1)/10)*param.resFac round(sizeIm(2)/5*4)*param.resFac round(sizeIm(1)/5*4)*param.resFac], 'EdgeColor', 'r', 'LineWidth', 2)
    hold off
    subplot(1,2,2)
    imshow(imresize(fliplr(img2_bin), param.resFac))
    %imshow(img2_bin)
    mtit('Put the LEFT hand sideways INSIDE the rectangle; Press -s- to capture the hand');
    
    pause(0.1);
    
    button = get(gcf,'CurrentCharacter');
    switch button
        case 113 %q
            %stop = 1;
            %set(gcf,'CurrentCharacter','@');
        case 115 %s
            %hand = snapshot(cam);
            hand = img;
            maskRaw = img2_bin;
            stop = 1;
            set(gcf,'CurrentCharacter','@');
    end
    
end %while ~stop
close(h1)


%--------------------------------------------------------------------------
%Process mask
[shapeFinal, centroid, mask] = processMask(maskRaw, hand, dirResults, filename, param, 0, savefile);


%--------------------------------------
%ROI Palm
[ROI, errorC, resultsROI, rotPalm, rotBw, top1, top2, bottom1, bottom2, grad, gradRefined] = findROI_fromShape(hand, mask, shapeFinal, centroid, param, dbname, filename, dirResults, savefile, plotta);


%--------------------------------------
%ROI fingers
errorF = 0;
ROI_fingers = cell(4 ,1);
if numel(find(errorC==-1)) == 0
    [ROI_fingers, rotROI_fingers, errorF] = extractFingers(rotPalm, rotBw, top1, top2, bottom1, bottom2, grad, gradRefined, param, dbname, filename, dirResults, savefile, plotta);
end %numel(find(errorC==-1))


%--------------------------------------
%Errors
%if numel(ROI) == 0 && errorC == -1
if numel(find(errorC==-1)) >= 1 || errorF == -1
    fprintf(1, 'Error: cannot extract ROI\n');
    returnCodeAcq = -1;
    ROI = [];
    ROI_fingers = [];
    %continue
else %if errorC
    returnCodeAcq = 1;
end %if errorC


