%% TX
clear
NFFT =1024	;  %FFT size
Fs =9600		;  % Sampling Freq. 
Nf =4	;   % Number of data carriers
m_ary =	4;  % Modulation for each carrier
SNR =	40	;   % Channel SNR 
Nsymb = 4;
 
% Create the bits tro transmit. They must be an integer multiple of Nf

txbits= round(rand(8));
 
%Create the amplitude vector base don the bits vector.
mod = ¿¿??;
 
% Insert digitally modulated symbols into the OFDM modulator
[ofdmSymbolsPa,ofdmSymbolsSe,ofdmSymbolsFreq,ofdmSymbolsFreqCont]=OFDMMod(xmod);

 
x = ¿? % Signal to be transmitted
 
    %% Channel
    SNR =?¿?¿;
    [PotTxdB,noise,PotN_OFDM]=NoiseGenerator(SNR,Nsymb);
    noise=noise/sqrt(PotN_OFDM);
    noise=noise*sqrt(10^(-SNR/10));
    
    y=x+noise;
    
 
%% RX
 
% User the OFDM demodulator to obtain the digitally modulated symbols
    [modSymbols,Y_symbol]=OFDMDemod(y);

 
% Demodulate the digital symbols obtained from the OFDM subcarriers.
rxbits= ¿?¿?;
 
BER =		; %Compute BER
 
%PLOTS
close all
f = linspace(-.5,.5,NFFT)*Fs;
stem(f*1e-3,abs(fftshift(fft(ofdmSymbolsPa))));
xlabel(‘Freq. [kHz]')
title('Transmitted Spectrum')
lgnStr = 'Symbol ';
nSymb = length(txbits)/Nf/log2(m_ary);
lgnStr =repmat(lgnStr,nSymb,1);
lgnStr = [lgnStr,num2str((1:nSymb)')];
legend(lgnStr);
 
figure
stem(f*1e-3,abs((Y_symbol)));
xlabel('Freq.[kHz]')
title('Received Spectrum')
legend(lgnStr);
 
 
h=scatterplot(modSymbols,1,0,'b.');hold on;% Received Constellation
 
scatterplot(exp(1i*2*pi/m_ary*(1:m_ary)),1,0,'r+',h);grid; %Constellation after channel

legend('Rx Symbols', 'Tx Symbols')

%% For the BER Vs. SNR performance
figure
semilogy(SNR_vector,BER)
hold on
BERTheo = qfunc(sqrt(2*10.^(SNR_vector/10))); % DBPSK

BERTheo(find(BERTheo<1e-5)) = NaN;
semilogy(SNR_vector,BERTheo,'r');
legend('Simulated','Theoretical')
xlabel('SNR [dB]');
ylabel('BER')
grid on 
title('Performance for OFDM System')
