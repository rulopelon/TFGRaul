function [PotTx,WGNoise,PotTotN_freqOFDM]=NoiseGenerator(SNR,nSym)

Fs = 30e3;  % Freq. muestreo
NFFT = 128;

% Vector de ruido con el que trabajo. 
WGNoise = wgn(1,nSym*NFFT,0);

%calculo el espectro
Spectrum_total_noise=fftshift(fft(WGNoise));
Spectrum_total_noise=Spectrum_total_noise/sqrt(length(Spectrum_total_noise));

f=Fs/2*linspace(-1,1,length(Spectrum_total_noise/2));  %frecuencias del espectro
% Calculo la banda de transmision
ind=find((f<-6.4e3 & f>-8.75e3) | (f>6.4e3 & f<8.75e3));
% Calculo la potencia del ruido en la banda de Tx con Parseval
PotTotN_freqOFDM=sum(abs(Spectrum_total_noise(ind)).^2)/length(Spectrum_total_noise(:));

%Unicamente tengo en cuenta el ruido que afecta a mi banda
PotTx=10*log10(PotTotN_freqOFDM)+SNR;





% 
% 
% 
% function ind=find_carriers2(f,modo)
% 
% switch modo
%     case 'PRIME'
%         ind=find((f<89e3 & f>42e3)| (f<-42e3 & f>-89e3));
%     case 'comb'
%         ind=find((f<111.4e3 & f>14.4e3)| (f<-13.8e3 & f>-110.85e3));
% end
% 
% 
% function ind=find_carriers(f,modo,environ)
% % Aqu� saco los �ndices de f
% load(strcat('../',environ));
% 
% if isstruct(modo)
%     if strcmp(modo.modo,'comb')
%         % en modo.mascara_info son los indices que llevan informacion en las frecuencias del OFDM de NIFFT muestras
%         ind=[fliplr(modo.mascara_info),modo.mascara_info];
%         ind=logical(ind);
%     end
% elseif strcmp(modo,'PRIME')
%     ind=find((f<89e3 & f>42e3)| (f<-42e3 & f>-89e3));
% end
% 
% % 
% % function PotTotN_freqOFDM=otro_modo(total_noise,modo,environ)
% % 
% % load(strcat('../',environ));
% % %
% % % Spectrum_total_noise=fftshift(fft(total_noise));
% % % PotTotN_freq=sum(abs(Spectrum_total_noise.^2))/length(Spectrum_total_noise).^2;
% % % f=Fs/2*linspace(-1,1,length(Spectrum_total_noise/2));  %frecuencias del espectro
% % % ind=find_carriers2(f,modo); %Frecuencias de la banda del OFDM
% % % PotTotN_freqOFDM=sum(abs(Spectrum_total_noise(ind).^2))/length(Spectrum_total_noise(:)).^2;
% % %
% % 
% % 
% % Spectrum_total_noise=fftshift(fft(total_noise))/sqrt(length(total_noise));
% % PotTotN_freq=sum(abs(Spectrum_total_noise.^2))/length(Spectrum_total_noise).^2;
% % f=Fs/2*linspace(-1,1,length(Spectrum_total_noise/2));  %frecuencias del espectro
% % ind=find_carriers2(f,modo); %Frecuencias de la banda del OFDM
% % PotTotN_freqOFDM=sum(abs(Spectrum_total_noise(ind).^2))/length(Spectrum_total_noise(ind));
% % 
