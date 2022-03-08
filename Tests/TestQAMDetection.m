%% Code to test the QAMDetection function
%clear, clc, close all force;
load("variables.mat","prefix_length")
% An OFDM signal is generated 
[signal,signal_reference] = OFDMModV2(1);

signal_test = signal_reference(prefix_length+1:end);
signal_test = fftshift(fft(signal_test));

reconstructed = QAMDetection(signal_test);
difference = signal_test-reconstructed;

figure
plot(abs(difference))
title("Error")