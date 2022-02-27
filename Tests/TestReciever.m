%% Code to test the reciever
% Inizialization
clear, clc, close all force;
load("variables.mat","Nsym","Fs_used")


% An OFDM signal is generated with random symbols
[signal,signal_reference] = OFDMModV2(10);

% The signal is shifted in frequency
n = 0:1:length(signal)-1;
shift =0/length(signal);    
signal_noise_shift = signal.*exp(-1i*2*pi*shift*n');

signal_noise_shift = [zeros(1000,1);signal_noise_shift];
processed_signal = Reciever(signal_noise_shift);




