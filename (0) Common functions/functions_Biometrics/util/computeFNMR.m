function [FNMR] = computeFNMR(gmsVector, REJngra, threshold)

%FNMR = (length(find(sort(gmsVector) < threshold)) + REJngra) / (length(gmsVector) + REJngra);


%distribuzione con valori grandi tipici degli  impostori (es. iride)
FNMR = (length(find(sort(gmsVector) > threshold)) + REJngra) / (length(gmsVector) + REJngra);