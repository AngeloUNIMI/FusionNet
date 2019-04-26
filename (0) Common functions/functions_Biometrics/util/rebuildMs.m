function msVector = rebuildMs(msN, msX)

msVector = [];
% trasformi i vettori di frequenza in un vettore lineare
for i = 1:length(msX)
    for j = 1:msN(i)
        msVector = [msVector msX(i)];
    end
end