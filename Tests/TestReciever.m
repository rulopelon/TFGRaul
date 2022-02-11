%% Code to test the reciever
% Inizialization
clear, clc, close all force;
parameters;
global Fs_used
% An OFDM signal is generated with random symbols
[~,signal] = OFDMModV2(1);

% The signal is shifted in frequency
n = 0:1:length(signal)-1;
shift =0/length(signal);
disp("Shift: "+shift*Fs_used)
signal_noise_shift = signal.*exp(-1i*shift*n);
%processed_signal = Simple_reciever(signal_noise);

frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();
for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end
i_frequency_reference = ifft(ifftshift(frequency_reference));
frequency_reference = fftshift(fft(i_frequency_reference,length(signal_noise_shift)));
%%
% Frequency deviation is calculated
[frequency_correlation,lags_freq] = xcorr(fft(signal_noise_shift),frequency_reference*7.14);
figure
plot(lags_freq,abs(frequency_correlation))
[~,index_max_freq] = max(frequency_correlation);
index_max_freq = lags_freq(index_max_freq);

f = linspace(-0.5,0.5,length(signal))*Fs_used;
figure
sgtitle("Signals")
subplot(2,1,1)

plot(abs(fft(signal)))
title("Original")

subplot(2,1,2)
%stem(f,abs(frequency_reference)*7.14)
plot(abs(fft(signal_noise_shift)))


title("Desplazada")


% Reconstructing the signal manually
% manual_proccessed_signal = signal_noise_shift.*exp(1i*shift*n);
% manual_proccessed_signal = manual_proccessed_signal(samples_noise+1:end);
