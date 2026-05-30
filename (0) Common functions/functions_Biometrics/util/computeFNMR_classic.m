function [FNMR] = computeFNMR_classic(gmsVector, REJngra, threshold)

FNMR = (length(find(sort(gmsVector) < threshold)) + REJngra) / (length(gmsVector) + REJngra);

