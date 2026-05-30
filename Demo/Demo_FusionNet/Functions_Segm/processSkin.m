function out = processSkin(img)

out = img(:,:,1) - img(:,:,2);