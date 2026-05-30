function [zeroFMR, zeroFNMR, iZFMR, iZFNMR] = computeZeroFMRFNMRindex(FMR, FNMR)


% zeroFMR = min(FNMR(find(FMR == 0)));
% zeroFNMR = min(FMR(find(FNMR == 0)));
% 
% % correction on indexes
% if isempty(zeroFMR)
%     zeroFMR = 1;
% end
% if isempty(zeroFNMR)
%     zeroFNMR = 0;
% end


zeroFMR = [];
zeroFNMR = [];
indiciZFMR = find(FMR == 0);
indiciZFNMR = find(FNMR == 0);
if isempty(indiciZFMR) == false
    [zeroFMR, iFMR1] = min(FNMR(indiciZFMR));
end
if isempty(indiciZFNMR) == false
    [zeroFNMR, iFNMR1]= min(FMR(indiciZFNMR));
end




% correction on indexes
if isempty(zeroFMR)
    zeroFMR = 1;
    iZFMR = -1;
else
    iZFMR = indiciZFMR(iFMR1);
end
if isempty(zeroFNMR)
    zeroFNMR = 0;
    iZFNMR = -1;
else
    iZFNMR = indiciZFNMR(iFNMR1);
end