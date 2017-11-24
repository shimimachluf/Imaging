function varargout=localmin(varargin)

% [ind,val]=localmin(V) find the index of the local minimum of the vector V
% and the value of V at this point. 
% [ind1,ind2, ...,val]=localmin(V) find the indices of a local minimum for
% multidimensional V.
% [x1,x2, ...,val]=localmin(coords,V,method) - find the local minimum of V.
% Coords is a cell array cotaining the coordinates of V.
% 

nox=1;
if nargin==1, % localmin(V)
    V=varargin{1};
    method='discrete';
elseif isnumeric(varargin{1}) || iscell(varargin{1}), % localmin(x,V)
    if isnumeric(varargin{2}),
        V=varargin{2};
        x=varargin{1};
        if iscell(x) && length(x)==1,
            x=x{1};
        end;
        nox=0;
        if nargin==3,
            method=varargin{3};
        else method='discrete';
        end;
    elseif ischar(varargin{2}), % localmin(V,'method')
        method=varargin{2};
        V=varargin{1};
    end;
end;

sz0=size(V);
n0=length(sz0);
vdims=find(sz0>1);
n=length(vdims);
if (n0>2) && (n<n0),
    V=squeeze(V);
    sz=size(V);
else sz=sz0;
end;
if (n==1)
    V=V(:);
    sz=size(V);
end;

cond=ones(sz);
for j=1:n,
    dx=diff(V,1,j);
    s=sz;
    s(j)=1;
    z=zeros(s);
    cond=cond & (cat(j,z,dx)<0) & (cat(j,dx,z)>0);
end;
inds=cell(1,n);
j=find(cond);
[inds{:}]=ind2sub(sz,j);
val=V(j);
freq=[];

if method(1)=='c', % cubic fit
    k=2;
    while k<=length(j),
        cond=ones(k-1,1);
        for l=1:length(inds),
            cond=cond & abs(inds{l}(k)-inds{l}(1:k-1))<=1;
        end;
        m=find(cond);
        if ~isempty(m),
            if val(m)<val(k),
                m=k;
            end;
            for l=1:length(inds),
                 inds{l}=inds{l}([1:m-1,m+1:end]);
            end;
            val=val([1:m-1,m+1:end]);
            j=j([1:m-1,m+1:end]);
        else k=k+1;
        end;
    end;
    if nox,
        if n>1,
            for j=1:length(sz),
                x{j}=[1:sz(j)];
            end;
        else x=[1:length(V)];
        end;
    end;
    for k=1:length(inds{1}),
        switch n,
            case 1,
                p=polyfit((x(inds{1}(k)+[-1:1])-x(inds{1}(k)))',V(inds{1}(k)+[-1:1]),2);
                pd=polyder(p);
                dx=-pd(2)/pd(1);
                inds{1}(k)=x(inds{1}(k))+dx;
                val(k)=polyval(p,dx);
                freq(k)=p(1);
            case 2,
                p1=polyfit((x{1}(inds{1}(k)+[-1:1])-x{1}(inds{1}(k)))',V(inds{1}(k)+[-1:1],inds{2}(k)),2);
                p1d=polyder(p1);
                dx1=-p1d(2)/p1d(1);
                q1=polyfit((x{2}(inds{2}(k)+[-1:1])-x{2}(inds{2}(k))),V(inds{1}(k),inds{2}(k)+[-1:1]),2);
                q1d=polyder(q1);
                dy1=-q1d(2)/q1d(1);
                sx=sign(dx1);
                sy=sign(dy1);
                p2=polyfit((x{1}(inds{1}(k)+[-1:1])-x{1}(inds{1}(k)))',V(inds{1}(k)+[-1:1],inds{2}(k)+sy),2);
                p2d=polyder(p2);
                dx2=-p2d(2)/p2d(1);
                q2=polyfit((x{2}(inds{2}(k)+[-1:1])-x{2}(inds{2}(k))),V(inds{1}(k)+sx,inds{2}(k)+[-1:1]),2);
                q2d=polyder(q2);
                dy2=-q2d(2)/q2d(1);
                x1=[0 ; dx1];
                x2=[sy ; dx2];
                y1=[dy1 ; 0];
                y2=[dy2; sx];
                lambda=[(x2-x1),-(y2-y1)]\(y1-x1);
                dx0=lambda(1)*(x2-x1)+x1;
                val(k)=interp2(V(inds{1}(k)+[-1:1],inds{2}(k)+[-1:1]),2+dx0(1),2+dx0(2),'cubic');
                inds{1}(k)=x{1}(inds{1}(k))+dx0(2);
                inds{2}(k)=x{2}(inds{2}(k))+dx0(1);
                freq(:,k)=[p1(1),q1(1)];
            case 3,
                for l=1:3,
                    inds{l}(k)=x{l}(inds{l}(k));
                end;
            end;
        end;
end;

if (n0>2),
    varargout=num2cell(ones(1,n0));
    varargout(vdims)=inds;
    n=n0;
else
    varargout(1:n)=inds;
end;

if nargout>n,
    varargout{n+1}=val;
end;
varargout{n+2}=freq;

    