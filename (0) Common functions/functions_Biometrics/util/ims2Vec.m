function [imsVector, imsVectorREJ, NIRA, REJnira] = ims2Vec(ims, matching_type)

% initialize vector
imsVector = [];
imsVeectorREJ = [];

k = 0;
w = 0;
% ciclo tutta la matrice per creare l'opportuno vettore
for i = 1:size(ims,1)
    % imposto J per saltare la met� inferiore della matrice se necessario
    switch (matching_type)
        case 'asymmetric'
            j = 1;
        otherwise
            j = i + 1;
    end
    for j = j:size(ims,2)
        % skip the diagonal matching
        if i~=j
            % exclude errors (-1 e -2)
            if ((ims(i,j) ~= -1) & (ims(i,j) ~= -2))
                k = k + 1;
                imsVector(k) = ims(i,j);
            end
            w = w + 1;
            imsVectorREJ(w) = ims(i,j);
        end
    end
end

NIRA = length(imsVector);
REJnira = length(imsVectorREJ) - NIRA;