clc
clear all
close all
addpath('./util');


dirDBIn = '..\images\DB Fusion Palm-Knuckle (orig)\REST_hand_database\';
dirDBOut = '..\images\DB Fusion Palm-Knuckle (test)\REST_hand_database\';
mkdir_pers(dirDBOut, 1);

dirs = list_only_subfolders(dirDBIn);

extIn = '.jpg';
extOut = extIn;

%left
lastInd = -1;
for d = 1 : numel(dirs)
    
    dirC = [dirDBIn dirs{d} '\Hand\Left\'];
    files = dir([dirC '*' extIn]);
    
    for i = 1 : numel(files)
        
        filename = files(i).name;
        
        if strcmp(extOut, extIn) == 0
            im = imread([dirC filename]);
        end
        
        fprintf(1, '%s\n', filename);
        
        [C, I] = strsplit(filename, {'_', '.'});
        ind = [C{1}];
        ind(1) = [];
        ind = str2double(ind);
        sampleid = str2double(C{end-1});
        
        if ind > lastInd
            lastInd = ind;
        end %if ind
        
        if sampleid > 4
            %continue
        end %if sampleid
        
        newfilename = [sprintf('%04.0f', ind) '_' sprintf('%04.0f', sampleid) extOut];
        
        %write
        if strcmp(extOut, extIn) == 1
            copyfile([dirC filename], [dirDBOut newfilename]);
        elseif strcmp(extOut, '.jpg') == 1
            imwrite(im, [dirDBOut newfilename], 'Quality', 100);
        else
            imwrite(im, [dirDBOut newfilename]);
        end
        
%         pause
        
    end %for i
    
end %for d


% pause

%right
for d = 1 : numel(dirs)
    
    dirC = [dirDBIn dirs{d} '\Hand\Right\'];
    files = dir([dirC '*.jpg']);
    
    for i = 1 : numel(files)
        
        filename = files(i).name;
        
        if strcmp(extOut, extIn) == 0
            im = imread([dirC filename]);
        end
        
        fprintf(1, '%s\n', filename);
        
        [C, I] = strsplit(filename, {'_', '.'});
        ind = [C{1}];
        ind(1) = [];
        ind = str2double(ind);
        sampleid = str2double(C{end-1});
        
        ind = ind + lastInd;
    
        if sampleid > 4
            %continue
        end %if sampleid
        
        newfilename = [sprintf('%04.0f', ind) '_' sprintf('%04.0f', sampleid) extOut];
        
        %write
        if strcmp(extOut, extIn) == 1
            copyfile([dirC filename], [dirDBOut newfilename]);
        elseif strcmp(extOut, '.jpg') == 1
            imwrite(im, [dirDBOut newfilename], 'Quality', 100);
        else
            imwrite(im, [dirDBOut newfilename]);
        end
        
%         pause
        
    end %for i
    
end %for d
