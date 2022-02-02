%% Code to test the reciever
% Inizialization
clear, clc, close all force;
parameters;

% An OFDM signal is generated with random symbols
signal = OFDMModV2(randi(200));
% random noise is added to the signal
samples_noise = randi(200);
signal_noise = [rand(1,samples_noise),signal];
disp("Samples of noise: "+samples_noise)

% The signal is shifted in frequency
n = 0:1:length(signal_noise)-1;
shift = randi([-50,50])/length(signal_noise);
disp("Shift: "+shift)
signal_noise_shift = signal_noise.*exp(-1i*shift*n);
processed_signal = Simple_reciever(signal_noise);

% Reconstructing the signal manually
manual_proccessed_signal = signal_noise_shift.*exp(1i*shift*n);
manual_proccessed_signal = manual_proccessed_signal(samples_noise+1:end);
%% Plot results
figure
subplot(1,4,1)
plot(abs(fftshift(fft(signal))));
title("Original signal")
subplot(1,4,2)
plot(abs(fftshift(fft(signal_noise))));
title("Signal with noise")
subplot(1,4,3)
plot(abs(fftshift(fft(signal_noise))));
title("Signal with noise and shifted")
subplot(1,4,4)
plot(abs(fftshift(fft(processed_signal))));
title("Signal reconstructed")