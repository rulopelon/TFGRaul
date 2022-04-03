%% Code to test if symbol synchronization works properly
clear,clc,close all force;
load("variables.mat","PROPAGATION_VELOCITY","Fs","Nsym")
[signal,signal_reference] = OFDMModV2(20);

% The surveillance signal is retarded

coeficients_retard = 0:1/Fs:1e3/PROPAGATION_VELOCITY;
coeficients_retard(1:end-1) = 0;
coeficients_retard(end) = 1;
signal_surveillance = conv(coeficients_retard,signal_reference);  

%Simulating the bounce
% The signal is shifted in frequency
n = 0:1:length(signal_surveillance)-1;
shift =20/length(signal_surveillance);    
signal_surveillance = signal_surveillance.*exp(-1i*2*pi*shift*n);
signal_surveillance = conv(coeficients_retard,signal_surveillance);

%Direct signal calculation
direct_signal = conv(coeficients_retard,signal_reference);
% Adding two signals
signal_surveillance = signal_surveillance(1:length(signal_reference))+direct_signal(1:length(signal_reference));
% Synchronization
a = symbolSynchronization(signal_surveillance.');