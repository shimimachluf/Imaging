function [ x_unique, yMean, yStd, N_unique ] = meanX( x, y )
% meanX calcualtes the mean y value and its standard deviation, per value of x
% plot results using: errorbar(x_unique,yMean,yStd,'o')
% [ x_uniqe, yMean, yStd ] = meanX( x, y )

[x_unique,m,n]=unique(x);
yMean=zeros(1,length(m));
yStd=zeros(1,length(m));
N_unique=zeros(1,length(m));
for j=1:length(m)
    yMean(j)=mean( y(n==j ));
    yStd(j)=std( y(n==j));
    N_unique(j) = sum(n==j);
end

end