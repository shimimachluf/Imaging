function [optrefimages] = fringeremoval(absimages,refimages,bgmask,method)
% FRINGEREMOVAL - Fringe noise removal from absorption images.
% Creates an optimal reference image for each absorption image in a set as
% a linear combination of reference images with coefficients chosen to
% minimize least-squares residuals between absorption image and optimal
% reference image.
% The coefficients are obtained by solving a linear set of equations using
% matrix inverse by LU decomposition or singular value decomposition (SVD).
%
% Algorithm inspired by J. Kronjaeger PhD thesis (Hamburg-2007).
%
% Syntax:
%   [optrefimages] = fringeremoval(absimages,refimages,bgmask,method);
%
% Required inputs:
% absimages - Cell array of absorption images
% refimages - Cell array of raw reference images
%   The number of refimages can differ from the number of absimages.
%
% Optional inputs:
% bgmask -  Array specifying background region used, 
%           1=background, 0=data. Defaults to all ones. 
% method -  Method used for solving linear equations. 
%           String containing 'LU' (default) or 'SVD'.
% 
% Outputs:
% optrefimages - Cell array or of optimal reference images, equal in length to absimages.
%
% Email:
% May 2009; Last revision: 14 July 2010
% Dependencies: none
% Authors: Shannon Whitlock, Caspar Ockeloen
% Reference: C. F. Ockeloen, A. F. Tauschinsky, R. J. C. Spreeuw, and
% S. Whitlock, Improved detection of small atom numbers through image processing, arXiv:1007.2136

% Process inputs
svd = strcmpi(method,'svd'); % Default to LU
nimgs = length(absimages);
nimgsR = length(refimages);
xdim = size(absimages{1},2);
ydim = size(absimages{1},1);
% if not(exist('bgmask','var'))
%     bgmask=ones(ydim,xdim);
% end
k = find(bgmask(:)==1); % Index k specifying background region

% Flatten absorption and reference images
R = double(reshape(cat(3,refimages{:}),xdim*ydim,nimgsR));
A = double(reshape(cat(3,absimages{:}),xdim*ydim,nimgs));

% Ensure there are no duplicate reference images
% R=unique(R','rows')'; % comment this line if you run out of memory

% Invert B = R*R' with the chosen method
if svd
    Binv = pinv(R(k,:)'*R(k,:)); % SVD through PINV
else
    [L,U,p] = lu(R(k,:)'*R(k,:),'vector'); % LU decomposition
end

optrefimages=cell(nimgs,1);
for j=1:nimgs
    b=R(k,:)'*A(k,j);
    % Obtain coefficients c which minimise least-square residuals
    if svd
        c = Binv*b;
        c1 = pinv(R(k,:)'*R(k,:))*R(k,:)'*A(k,j);
        Binv2 = pinv(R(k,:)'*R(k,:))*R(k,:)';
        c2 = Binv2*A(k,j);
        Binv3 = (R(k,:)'*R(k,:))\R(k,:)';
        c3 = Binv3*A(k,j);
%         Binv4 = R(k,:)*((R(k,:)'*R(k,:))\R(k,:)'); % mareix too large
%         c4 = Binv4*A(k,j);
    else
        lower.LT = true; upper.UT = true;
        c = linsolve(U,linsolve(L,b(p,:),lower),upper);
    end
    
    % Compute optimised reference image
    optrefimages{j}=reshape(R*c,[ydim xdim]);
%     optrefimages1=reshape(c4,[ydim xdim]);
end

if nimgs == 1
    optrefimages = optrefimages{1};
end

