clc
clear
close all
addpath('./util');

dirBase = '..\images\DB Fusion Palm-Knuckle (test)\';
dbname = 'REST_hand_database';
ext = '.jpg';

%base
dirs_all = {...
    [dirBase dbname '\ROIs_possible\'] ...
    [dirBase dbname '\ROIs_fing_1\'] ...
    [dirBase dbname '\ROIs_fing_2\'] ...
    [dirBase dbname '\ROIs_fing_3\'] ...
    [dirBase dbname '\ROIs_fing_4\'] ...
    };

%flipped
dirBaseFlipped = [dirBase dbname '_flipped\'];
mkdir_pers(dirBaseFlipped, 1);
dirs_all_flipped = {...
    [dirBaseFlipped '\ROIs_possible\'] ...
    [dirBaseFlipped '\ROIs_fing_1\'] ...
    [dirBaseFlipped '\ROIs_fing_2\'] ...
    [dirBaseFlipped '\ROIs_fing_3\'] ...
    [dirBaseFlipped '\ROIs_fing_4\'] ...
    };
for d = 1 : numel(dirs_all_flipped)
    mkdir_pers(dirs_all_flipped{d}, 1);
end %for d

%flip table (es. fliptable(1) = 4
fliptable = [4, 3, 2, 1];

%loop
for d = 1 : numel(dirs_all)
    files = dir([dirs_all{d} '*' ext]);
    for i = 1 : numel(files)
        name = files(i).name;
        ind_id = str2double(name(1:4));
        sample_id = str2double(name(6:9));
        
        %copy to the same dir
        if ind_id < 180
            copyfile([dirs_all{d} files(i).name], [dirs_all_flipped{d} files(i).name]);
        end %if exist
        
        %flip and copy to corr dir
        if ind_id >= 180
            if d >= 2 %flip only the fingers
                im = imread([dirs_all{d} files(i).name]);
                %im = fliplr(im);
                ind_flip = fliptable(d-1)+1;
                imwrite(im, [dirs_all_flipped{ind_flip} files(i).name]);
            else %if d
               copyfile([dirs_all{d} files(i).name], [dirs_all_flipped{d} files(i).name]); 
            end %if d
        end %if exist
    end %for i
end %for d






