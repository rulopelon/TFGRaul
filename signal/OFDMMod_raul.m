function [ofdmSymbolsPa,ofdmSymbolsSe,ofdmSymbolsFreq,ofdmSymbolsFreqCont]=OFDMMod(modSymbols,fc,NFFT)
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY
%  function [ofdmSymbolsPa,ofdmSymbolsSe,ofdmSymbolsFreq,ofdmSymbolsFreqCont]=OFDMMod(modSymbols)

%  - modSymbols . Vector with the constellation symbols for the Nf data carriers.
%  this vector needs to have a length which is an integer number of times
%  Nf.
% 
%  - ofdmSymbolsPa . Matrix with the OFDM modulated symbols (in time domain). 
%   This matrix has as many rows as the size of the FFT and as many columns as the number of OFDM simbols to transmit.
%  - ofdmSymbolsSe . Vector with the OFDM modulated symbols (in time
%  domain). This vecto has all symbols that ofdmSymbolsPa has but arranged
%  in only one dimesion
%  - ofdmSymbolsFreq . Vecto with the FFT of the first symbol.
%  - ofdmSymbolsFreqCont . Vector with the Continuous-Time Fourier
%  Transform of the first symbol



PLOT  = false;
Fs = 30e3;
Nf = 4;   % Number of data carriers
NFFTcont = 2^20;



h = comm.PSKModulator('ModulationOrder',4,'SymbolMapping','gray','BitInput',true,'PhaseOffset',0);
modSymbols = h(modSymbols);
modSymbols = modSymbols(:).'; % arrange in row

if mod(length(modSymbols),Nf)~=0
    error('modSymbols'' length must be an integer number of tines Nf') ;
end

Nsym = length(modSymbols)/Nf;
modSymbolsBlock = reshape(modSymbols,length(modSymbols)/Nsym,Nsym).';

ofdmSymbolsFreq =[zeros(Nsym,((NFFT/2)-Nf)/2) conj(fliplr(modSymbolsBlock))  zeros(Nsym,((NFFT/2)-Nf)/2)  zeros(Nsym,(((NFFT/2)-Nf)/2)+1)  modSymbolsBlock zeros(Nsym,(((NFFT/2)-Nf)/2)-1)];

ofdmSymbolsPa = (NFFT/sqrt((Nf)*2))*ifft(ofdmSymbolsFreq.');

ofdmSymbolsFreqCont= fft(ofdmSymbolsPa(:,1),NFFTcont).'/(NFFT/sqrt((Nf)*2));
ofdmSymbolsFreq = fft(ofdmSymbolsPa(:,1)).'/(NFFT/sqrt((Nf)*2));

ofdmSymbolsSe = reshape(ofdmSymbolsPa,1,Nsym*NFFT);
%The signal is multiplied by a carrier to move the frecuency to the desired
t = 0:1/Fs:(NFFT*Nsym-1)/Fs;

imaginary_part = imag(ofdmSymbolsSe).*cos(2*pi*fc*t);
real_part = real(ofdmSymbolsSe).*sin(2*pi*fc*t);
ofdmSymbolsSe = real_part+imaginary_part;
if PLOT
    % Plotting one OFDM symbol in frequency
    figure
    fcont=(0:NFFTcont-1)*Fs/NFFTcont; %Frequencies to plot the continuous-time FT
    figure,
    plot(1e-3*fcont(1:length(fcont)/2),(fliplr(ofdmSymbolsFreqCont(1:NFFTcont/2))),'r') % Positive spectrum
    f=(1:NFFT)*Fs/NFFT;         % Frequencies to plot the discrete FT
    hold on
    stem(1e-3*f(1:NFFT/2),(fliplr(ofdmSymbolsFreq(1:NFFT/2))))    % Positive spectrum
    
    title('Espectro continuo y discreto para 1 simbolo OFDM')
    legend('Espectro Continuo (sobre-muestreado)','Espectro Discreto')
    xlabel('Freq. [kHz]')
    grid on
    
%  time plotting 

figure,
nSymPlot = 3;
t = 0:1/Fs:(NFFT*nSymPlot-1)/Fs;
plot(t,reshape(ofdmSymbolsPa(:,1:nSymPlot),1,NFFT*nSymPlot))
xlabel('Time [ms]')
title(['Time representation of ',num2str(nSymPlot),' symbols'])

Nsym = nSymPlot;
mean(reshape(ofdmSymbolsPa(:,1:nSymPlot),1,NFFT*nSymPlot));
end