
clear times per A1 A2 err1 err2 amp1 amp2
per = 0;
times = [1000 2000 3000 4000 5000 7000 9000 11000];
A1 = ones(size(times));
A2 = ones(size(times));
err1 = ones(size(times));
err2 = ones(size(times));

for i =1 : length(times)
    try
        st = eval(['osc_' num2str(per) 'per_' num2str(times(i)) 'ms_mF2']);
        A2(i) = 1e3*abs(st.res.a); % in um
        conf = confint(st.res);
        err2(i) = abs(1e3*abs(conf(1,1)) - A2(i)); % in um
    catch ex
    end
    
    try
        st = eval(['osc_' num2str(per) 'per_' num2str(times(i)) 'ms_mF1']);
        A1(i) = 1e3*abs(st.res.a); % in um
        conf = confint(st.res);
        err1(i) = abs(1e3*conf(1,1) - A1(i)); % in um
    catch ex
    end
    
end

s1 = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [1 1], 'Weights', 1./err1.^2);
s2 = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [1 1], 'Weights', 1./err2.^2);
f1 = fittype('A*exp(-x/T)', 'coefficients', {'A', 'T'}, 'independent', 'x', 'dependent', 'y', 'options', s1);
f2 = fittype('A*exp(-x/T)', 'coefficients', {'A', 'T'}, 'independent', 'x', 'dependent', 'y', 'options', s2);
[amp1.res, amp1.gof, amp1.output] = fit(1e-3*times', A1', f1);
[amp2.res, amp2.gof, amp2.output] = fit(1e-3*times', A2', f2);

figure( 'FileName', 'F:\My Documents\Experimental\');
hold on
errorbar(1e-3*times, A1, err1, 'or');
errorbar(1e-3*times, A2, err2, 'ob');
plot(amp1.res, 'r');
plot(amp2.res, 'b');
hold off
title(['Oscillations Amplitude, (' num2str(per) ' per)'], 'interpreter', 'none');
xlabel('time [s]');
ylabel('amplitude [\mum]');
legend({['mF=1, (' num2str(per) ' per)'],['mF=2, (' num2str(per) ' per)']},'interpreter', 'none');
