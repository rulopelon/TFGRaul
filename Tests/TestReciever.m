%% Code to test the reciever
% Inizialization
clear, clc, close all force;
load("variables.mat","Fs_used","M","L")

% An OFDM signal is generated with random symbols
[signal,signal_reference] = OFDMModV2(10);

% The signal is shifted in frequency
n = 0:1:length(signal_reference)-1;
shift =500/length(signal_reference);    
disp("Shift: "+shift*Fs_used)
signal_noise_shift = signal_reference.*exp(-1i*2*pi*shift*n);

signal_noise_shift = [zeros(100,1);signal_noise_shift.'];
processed_signal = Reciever(signal_noise_shift);

% Difference between the processed signal an the reference signal
difference = processed_signal-signal_reference;
figure
plot(difference)
title("Processing error")


