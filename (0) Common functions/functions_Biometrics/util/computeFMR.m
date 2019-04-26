function [FMR] = computeFMR(imsVector, REJnira, threshold)

%FMR = length(find (sort(imsVector) >= threshold)) / (length(imsVector));


%distribuzione con valori grandi tipici degli  impostori (es. iride)
FMR = length(find (sort(imsVector) <= threshold)) / (length(imsVector));
