function out = sineFit(x, y, trapFreq)
% s2 = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [0.01 2 0 100 0]);
% s1 = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [0.01 2 0 70 0]);
% f1 = fittype('a*sin(2*pi*f*(x - p))+c+d*x', 'coefficients', {'a', 'c', 'd', 'f',  'p'}, 'independent', 'x', 'dependent', 'y', 'options', s1);
% f2 = fittype('a*sin(2*pi*f*(x - p))+c+d*x', 'coefficients', {'a', 'c', 'd', 'f',  'p'}, 'independent', 'x', 'dependent', 'y', 'options', s2);
s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [0.01 2 0 trapFreq 0]);
f = fittype('a*sin(2*pi*f*(x - p))+c+d*x', 'coefficients', {'a', 'c', 'd', 'f',  'p'}, 'independent', 'x', 'dependent', 'y', 'options', s);
[out.res, out.gof, out.output] = fit(x', y', f);
figure; plot(out.res, x', y')