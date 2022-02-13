function h = getFilter(M,L)
%Function to calculate filter using Parks-McClellan method
%Author: Carlos García de la Cueva
%Modified: Raúl Gonzále Gómez
load("variables.mat","PLOT","CARRIERS","NFFT")    

% Passband ripple
Rp = 0.05;
rp = 10^(Rp/20) - 1; 
% Rejected band attenuation in db
Att = 80;
att = 10^(-Att/20);
% Stop frequency
if L>M
    fc = 1/(2*L);
else
    fc = 1/(2*M);
end

% Transtion band
delta_f = ((NFFT-CARRIERS)/2);  % Delta is chosen
Df = (delta_f/NFFT)/M;

Nmin = (-10*log10(rp*att)-13)/(14.6*Df) + 1;
amp = [1 1 0 0];
% Frequency axis
freq = [0 fc fc+Df 0.5];
% Filter design 
h = firpm(ceil(Nmin),freq*2,amp,[att/rp, 1]); 
% Calculating frequency response
h = h/sum(h);
h = h*L;
H = fftshift(fft(h,NFFT));


if PLOT
    % Visualizing frequency response
    figure;
    a1 = axes;
    plot(a1,linspace(-0.5,0.5,length(H)),20*log10(abs(H)))
    xlabel(a1,'Normalized Frequency','Interpreter',"latex")
    ylabel(a1,'dB','Interpreter',"latex")
    title(a1,'$|H(e^{jw})|^2$',"Interpreter",'latex')
    grid(a1,'on')
end
    
    
end

