folder = '/Volumes/BackUp/Experimental_current/2012-07-17/fringes_5us_19ms TOF';
% folder = '/Volumes/BackUp/Experimental_current/2012-07-18/fringes_2';

nums_ = [300:355];
for j = 1 : 100
    nums = nums_(randperm(length(nums_)));
    atoms = (zeros(2050,750));
    back = (zeros(size(atoms)));
    for k = 1 : 25
        clear savedData
        load([folder '/data-' num2str(nums(k)) '.mat']);
        atoms = atoms + double(savedData.atoms);
        back = back  + double(savedData.back);
    end
    savedData.atoms = uint16(atoms / (k+1));%length(nums);
    savedData.back = uint16(back / (k+1));%length(nums);
    savedData.save.picNo = j;
    %         save([folder '/rand1 ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics/data-' num2str(k) '-' num2str(k+l) '.mat'], 'savedData');
    save([folder '/rand25-4/data-' num2str(j) '-' num2str(nums(1:k)) '.mat'], 'savedData');

end



% %% different sets of images
% nums_ = [300:355];
% nums = nums_(randperm(length(nums_)));
% % nums = [200:266];
% % nums = [9:73];
% for l = 5 : 5 : 25
% %     mkdir([folder '/rand1 ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics'])
%     mkdir([folder '/rand1/' num2str(l) ' pics'])
%     for m = 1 : length(nums)-l-1%k = nums(1) : nums(end)-l
%         k = nums(m);
%         atoms = (zeros(2050,750));
%         back = (zeros(size(atoms)));
%         for n = 0 : l %j = k : k+l
%             j = nums(m+n);
%             clear savedData
%             load([folder '/data-' num2str(j) '.mat']);
%             atoms = atoms + double(savedData.atoms);
%             back = back  + double(savedData.back);
%         end
%         savedData.atoms = uint16(atoms / (l+1));%length(nums);
%         savedData.back = uint16(back / (l+1));%length(nums);
%         savedData.save.picNo = k;
% %         save([folder '/rand1 ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics/data-' num2str(k) '-' num2str(k+l) '.mat'], 'savedData');
%         save([folder '/rand1/' num2str(l) ' pics/data-' num2str(k) '-' num2str(nums(m:m+l)) '.mat'], 'savedData');
%     
%     end
% end

% %% different sets of images
% nums_ = [300:355];
% nums = nums_(randperm(length(nums_)));
% % nums = [200:266];
% % nums = [9:73];
% for l = 5 : 5 : 25
% %     mkdir([folder '/rand1 ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics'])
%     mkdir([folder '/rand2/' num2str(l) ' pics'])
%     for m = 1 : length(nums)-l-1%k = nums(1) : nums(end)-l
%         k = nums(m);
%         atoms = (zeros(2050,750));
%         back = (zeros(size(atoms)));
%         for n = 0 : l %j = k : k+l
%             j = nums(m+n);
%             clear savedData
%             load([folder '/data-' num2str(j) '.mat']);
%             atoms = atoms + double(savedData.atoms);
%             back = back  + double(savedData.back);
%         end
%         savedData.atoms = uint16(atoms / (l+1));%length(nums);
%         savedData.back = uint16(back / (l+1));%length(nums);
%         savedData.save.picNo = k;
% %         save([folder '/rand1 ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics/data-' num2str(k) '-' num2str(k+l) '.mat'], 'savedData');
%         save([folder '/rand2/' num2str(l) ' pics/data-' num2str(k) '-' num2str(nums(m:m+l)) '.mat'], 'savedData');
%     
%     end
% end

% folder = '/Volumes/BackUp/Experimental_current/2012-07-17/fringes_5us_19ms TOF';
% % folder = '/Volumes/BackUp/Experimental_current/2012-07-18/fringes_2';
% 
% % different sets of images
% % nums = [300:355];
% nums = [200:266];
% % nums = [9:73];
% for l = 5 : 25
%     mkdir([folder '/mean ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics'])
%     for k = nums(1) : nums(end)-l
%         atoms = (zeros(2050,750));
%         back = (zeros(size(atoms)));
%         for j = k : k+l
%             clear savedData
%             load([folder '/data-' num2str(j) '.mat']);
%             atoms = atoms + double(savedData.atoms);
%             back = back  + double(savedData.back);
%         end
%         savedData.atoms = uint16(atoms / (l+1));%length(nums);
%         savedData.back = uint16(back / (l+1));%length(nums);
%         savedData.save.picNo = k;
%         save([folder '/mean ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics/data-' num2str(k) '-' num2str(k+l) '.mat'], 'savedData');
%     end
% end


% % folder = '/Volumes/BackUp/Experimental_current/2012-07-17/fringes_5us_19ms TOF';
% folder = '/Volumes/BackUp/Experimental_current/2012-07-18/fringes_2';
% 
% % different sets of images
% % nums = [300:355];
% % nums = [200:266];
% nums = [9:73];
% for l = 20 : 5 : 25
%     mkdir([folder '/mean ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics'])
%     for k = nums(1) : nums(end)-l
%         atoms = (zeros(2050,750));
%         back = (zeros(size(atoms)));
%         for j = k : k+l
%             load([folder '/data-' num2str(j) '.mat']);
%             atoms = atoms + double(savedData.atoms);
%             back = back  + double(savedData.back);
%         end
%         savedData.atoms = uint16(atoms / (l+1));%length(nums);
%         savedData.back = uint16(back / (l+1));%length(nums);
%         savedData.save.picNo = k;
%         save([folder '/mean ' num2str(nums(1)) '-' num2str(nums(end)) '/' num2str(l) ' pics/data-' num2str(k) '-' num2str(k+l) '.mat'], 'savedData');
%     end
% end


% %% random set of images
% 
% 
% %% random 1D fringes
% for k = 1:100
% phi = rand(1,14)*2*pi;
% for j=1:10; 
% x0 = rand(1,14)*40;
% % x0 = zeros(1,14);
%     yFit(j,:) =  obj.res.a*exp(-(y-obj.res.x0+x0(j)).^2/2/obj.res.w^2) .*  ...
%         (1+obj.res.v*sin(2*pi*(y)/obj.res.lambda+obj.res.phi+phi(j)))+obj.res.c; 
% end
% firstGuess = [0.3, 0,  8, 0, 0.1, 25, 180-mean(x0)];
% [res, gof, output] = fit(y',mean(yFit)',ft,fo);
% v(k) = res.v;
% k
% end
% 
% % 1 3 29 38? 41? 53? 76? 91 