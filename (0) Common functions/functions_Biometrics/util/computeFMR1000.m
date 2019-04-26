function [fmr1000, index, fmr1000_threshold] = computeFMR1000(FMR, FNMR, scores)

%FMR1000 (the lowest FNMR for FMR<=0.1%)
[fmr1000, index] = min(FNMR(find(FMR <= 0.001)));

% correction on indexes
if isempty(fmr1000)
    fmr1000 = 1;
    index = 0;
end

if nargin > 2
    fmr1000_threshold = scores(index);
end %if nargin > 2
