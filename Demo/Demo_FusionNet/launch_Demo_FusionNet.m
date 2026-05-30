clc
clear variables
close all


%--------------------------------------------------------------------------
%paths
addpath(genpath('./util'))
addpath(genpath('./Functions_Segm'))
addpath(genpath('./Functions_ROI'))
addpath(genpath('./Functions_ROI_finger'))
addpath(genpath('./Functions_Acquisiz'))
addpath(genpath('./Functions_FeatExtr'))
addpath(genpath('./Functions_CreaTemplate'))


%--------------------------------------------------------------------------
%gen params
plotta = 1;
savefile = 1;
log = 1;


%--------------------------------------------------------------------------
%db
dbname = 'webcam';
filename = getDateAng();
dirDB = './dirDB/';
mkdir_pers(dirDB, savefile);


%--------------------------------------------------------------------------
%models
dirModels = './models/';
submodels = list_only_subfolders(dirModels);


%--------------------------------------------------------------------------
%dirResults
dirResults = './results/';
mkdir_pers(dirResults, savefile);
%RESULT: log
timeStampRaw = datestr(datetime);
timeStamp = strrep(timeStampRaw, ':', '-');
if savefile && log
    logFile = [dirResults dbname '_log_' timeStamp '.txt'];
    %fidLog = fopen(logFile, 'a');
end %if log


%--------------------------------------------------------------------------
cam = webcam('integrated');
cam.Resolution = '640x480';
% cam.Brightness = 50;
% cam = webcam('Logitech');
% cam.Resolution = '1600x896';
% cam.Brightness = 150;


%--------------------------------------------------------------------------
%params
run(['./params/params_' dbname '.m']);


%--------------------------------------------------------------------------
%Scelta
str = input('Press -E- for enrollment; Press -R- for recognition: ', 's');


%--------------------------------------------------------------------------
%Enrollment
if strcmp(str, 'E') || strcmp(str, 'e')
    
    %name
    indNameStr = input('Individual name: ', 's');
    
    %loop on number of samples
    for s = 1 : param.numSamp
        
        sampNumStr = int2str(s);
        
        %display
        fprintf(1, ['\tIndividual: ' indNameStr '; Sample num: ' sampNumStr '\n']);
        
        %Crea template
        [featFusFeatLevel, bg, img] = creaTemplate(cam, dirResults, dirModels, submodels, filename, dbname, param, plotta, savefile);
        
        %save template
        save([dirDB indNameStr '_' sampNumStr '.mat'], 'featFusFeatLevel');
        imwrite(bg, [dirDB indNameStr '_' sampNumStr '_bg.bmp']);
        imwrite(img, [dirDB indNameStr '_' sampNumStr '_img.bmp']);
        
    end %for s
    
end %strcmp(str, 'E')


%--------------------------------------------------------------------------
%Recognition
if strcmp(str, 'R') || strcmp(str, 'r')
    
    %init dis
    distMax = 1e10;
    
    %Crea template
    featFusFeatLevelNew = creaTemplate(cam, dirResults, dirModels, submodels, filename, dbname, param, plotta, savefile);
    
    %loop on db
    filesDB = dir([dirDB '*.mat']);
    for i = 1 : numel(filesDB)
        
        %get ind name
        nameFileDB = filesDB(i).name;
        [C, ind] = strsplit(nameFileDB, '_');
        indName = [C{1:end-1}];
        
        %load
        load([dirDB nameFileDB]);
        
        %distance
        dist = full(fastEuclideanDistance(featFusFeatLevelNew, featFusFeatLevel));
        if dist < distMax
            distMax = dist;
            indNameChosen = indName;
        end %if dist
        
        %display
        fprintf(1, ['Comparison with: ' nameFileDB '; Distance: ' num2str(dist) '\n']);
        
    end %for i
    
    %display
    resTxt1 = ['Hand belongs to individual: ' indNameChosen];
    resTxt2 = ['Distance: ' num2str(distMax)];
    fprintf(1, [resTxt1 '\n']);
    fprintf(1, [resTxt2 '\n']);
    mydialog(resTxt1, resTxt2);
      
end %strcmp(str, 'R')
















