function [FMR] = computeFMR_classic(imsVector, REJnira, threshold)

FMR = length(find (sort(imsVector) >= threshold)) / (length(imsVector));

