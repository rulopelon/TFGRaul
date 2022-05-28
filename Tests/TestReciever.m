%% Code to test the reciever
% Inizialization
clear,clc,close all force;
load("variables.mat","PROPAGATION_VELOCITY","Fs","Nsym")
[signal,signal_reference] = OFDMModV2(Nsym);

%signal = signal.';
% The surveillance signal is retarded

%coeficients_retard = 0:1/Fs:1000/PROPAGATION_VELOCITY;
coeficients_retard = zeros(4000,1);
coeficients_retard(1:end-1) = 0;
coeficients_retard(end) = 1;
signal_surveillance = conv(coeficients_retard,signal);  

%Simulating the bounce
% The signal is shifted in frequency
n = 0:1:length(signal_surveillance)-1;
shift =30/length(signal_surveillance);    
signal_surveillance = signal_surveillance.*exp(-1i*2*pi*shift*n.');
signal_surveillance = conv(coeficients_retard,signal_surveillance);

%Direct signal calculation
direct_signal = conv(coeficients_retard,signal);
%direct_signal = signal;
% Adding two signals
signal_surveillance = signal_surveillance(1:length(signal))+direct_signal(1:length(signal));
% Synchronization
Reciever(signal_surveillance.');