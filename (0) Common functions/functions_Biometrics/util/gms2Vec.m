function [gmsVector, gmsVectorREJ, NGRA, REJngra] = gms2Vec(gms, matching_type)

% initialize vector
gmsVector = []; 
gmsVectorREJ = [];

k = 0;
w = 0;
for z = 1:size(gms,2) % for each ID
    % ciclo tutta la matrice per creare l'opportuno vettore
    for i = 1:size(gms{z},1)
        % imposto J per saltare la met� inferiore della matrice se necessario
        switch (matching_type)
            case 'asymmetric'
                j = 1;
            otherwise
                j = i + 1;
        end
        for j = j:size(gms{z},2)
            % skip the diagonal matching
            if i~=j
                % exclude errors (-1 e -2)
                if ((gms{z}(i,j) ~= -1) & (gms{z}(i,j) ~= -2))
                    k = k + 1;
                    gmsVector(k) = gms{z}(i,j);
                end
                w = w + 1;
                gmsVectorREJ(w) = gms{z}(i,j);
            end
        end
    end
end

NGRA = length(gmsVector);
REJngra = length(gmsVectorREJ) - NGRA; 


