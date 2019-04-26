function [filesProc, errorC] = balanceDB(files, maxNumInd, maxNumSampleInd)

%init
errorC = 0;
filesProc = files;

%loop on files to compute num of samples for each ind
numSamplePerInd = zeros(numel(filesProc), 1); %larger init to be sure
for i = 1 : numel(filesProc) 
    filename = filesProc(i).name;
    ind = str2double(getIndName(filename));
    numSamplePerInd(ind) = numSamplePerInd(ind) + 1;  
end %for i

%remove excess
im = find(numSamplePerInd, 1, 'last');
numSamplePerInd(im+1 : end) = [];

%remove individual without minimum number of samples
indexrem = [];
for i = 1 : numel(filesProc)
    filename = filesProc(i).name;
    ind = str2double(getIndName(filename)); %IITD
    if numSamplePerInd(ind) < maxNumSampleInd
        indexrem = [indexrem i];
    end %if numSamplePerInd(ind) == 1
end %for i
filesProc(indexrem) = [];

%check if there are enough
if numel(filesProc) < maxNumInd
    errorC = -1;
    return;
end %if numel(filesProc) < maxNumInd

%remove excess individuals
indexrem = [];
allInd = [];
for i = 1 : numel(filesProc)
    filename = filesProc(i).name;
    ind = str2double(getIndName(filename));
    
    if numel(find(allInd == ind)) == 0
        allInd = [allInd ind];
    end %if numel
    
    if numel(allInd) > maxNumInd
        %we can remove the others
        allInd(end) = [];
        indexrem = i : numel(filesProc);
        break;
    end %if numInd > maxNumInd
end %for i
filesProc(indexrem) = [];

%discard samples in excess
indexrem = [];
numSamplePerInd = zeros(numel(filesProc), 1); %larger init to be sure
for i = 1 : numel(filesProc) 
    filename = filesProc(i).name;
    ind = str2double(getIndName(filename));
    numSamplePerInd(ind) = numSamplePerInd(ind) + 1; 
    if numSamplePerInd(ind) > maxNumSampleInd
        indexrem = [indexrem i];
    end %if numSamplePerInd(ind) > maxNumSampleInd
end %for i   
filesProc(indexrem) = [];   
          
        
        
        