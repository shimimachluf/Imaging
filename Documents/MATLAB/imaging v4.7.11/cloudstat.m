function [n,g2,dN2]=cloudstat(t,pixsize,numAvgPixels,photonSN,normn)
% t is the totAppData cell array
% n is the atomic density for all the images per pixel
%  g2 is the second order coherence matrix
%  <n(x)n(x')>-(<n(x)\delta(x-x'))/(<n(x)><n(x')>
% dN2 is the correlation function <n(x)n(x')>-<n(x)><n(x')>

sigma_s=0.29; % scattering cross section in mu^2
fitType = t{1}.data.fitType;
nt=length(t);
nx=length(t{1}.data.fits{fitType}.xData);
n=zeros(nt,nx);
for j=1:nt,
    n(j,:)=t{j}.data.fits{fitType}.xData;
%     n(j,:)=(n(j,:)-0*t{j}.data.fits{13}.baseFit.xRes.Cx)*pixsize^2/sigma_s*numAvgPixels;
     n(j,:)=(n(j,:)-0*t{j}.data.fits{fitType}.xRes.Cx)*pixsize^2/sigma_s*numAvgPixels;
end;
n_tot=sum(n,2);
if normn,
    n=n./n_tot(:,ones(1,nx))*mean(n_tot);
end;
C=0;
for j=1:nt,
    C=C+n(j,:)'*n(j,:);
end;
C=C/nt-photonSN; % C is <n(x)n(x')> reduced by the photon shot noise
dN2=C-mean(n)'*mean(n);
g2=(C-diag(mean(n)))./(mean(n)'*mean(n));


