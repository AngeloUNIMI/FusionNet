function [EER, index, eer_threshold] = computeEER_classic_minDiffFprFnr(fpr_mean, fnr_mean, scores)

diffV = abs(fpr_mean-fnr_mean);

index = find(diffV == min(diffV));
index = index(1);

EER = (fpr_mean(index) + fnr_mean(index) ) / 2;

if nargin > 2
    eer_threshold = scores(index);
end %if nargin > 2