function indexes = computeReal(indexes, MATCHING_t)

LogWrite('Compute indexes ...');
% calcolo DET
[indexes.FMR, indexes.FNMR] = computeDET(indexes.gmsVector, indexes.imsVector, indexes.REJngra, indexes.REJnira, MATCHING_t);
% calcolo EER
[indexes.EER, indexes.EERlow, indexes.EERhigh] = computeEER(indexes.FMR, indexes.FNMR);
% calcolo ZeroFMR e ZeroFNMR
[indexes.zeroFMR, indexes.zeroFNMR] = computeZeroFMRFNMR(indexes.FMR, indexes.FNMR);