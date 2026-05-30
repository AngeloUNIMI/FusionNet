function nameFolds = list_only_subfolders(pathFolder)

d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';

nameFolds(ismember(nameFolds,{'.','..'})) = [];