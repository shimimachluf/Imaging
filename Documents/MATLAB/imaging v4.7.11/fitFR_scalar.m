function ret = fitFR_scalar(p, images, atoms, mask)
tic
% ret = zeros(size(atoms));
% for i = 1 : length(p)
%     ret = ret + p(i)*squeeze(images(i,:,:));%mask.*squeeze(images(i,:,:));
% end
ret = sum(bsxfun(@times,images,reshape(p,[1 1 length(p)])),3);
 
% ret = ret - atoms.*mask;
% ret = sum(sum(ret.^2))
ret = log( (ret + 1)./ (atoms + 1)  );
ret = (sum(sum(mask.*ret)))
% sum(p)
toc
end
