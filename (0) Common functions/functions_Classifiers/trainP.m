function P = trainP(Dic, numberOfSamples, param)

P = inv(Dic' * Dic + param.lambda * eye(numberOfSamples)) * Dic';


