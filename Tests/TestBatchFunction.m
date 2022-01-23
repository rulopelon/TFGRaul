% Code to test the BlockProcessing function
% Inizialization
clear, clc, close all force;
parameters;
% Forcing the function to plot the results
PLOT = false;

Fs = 1e6;       % just for quicker testing
t = 0:1/Fs:(1000020-1)/Fs;

samples = OFDMModV2(Nsym);
n = 0:1:length(samples)-1;
%% Samples are shifted on frequency 
shift = (1/length(samples))*0;

shifted = samples.*exp(-1i*2*pi*shift*n);
% Samples are analyzed
correlation_matrix_doppler= BatchProcessing(samples,shifted);
f = linspace(-0.5,0.5,length(samples));

figure
sgtitle("Frequencies signals shifted")

subplot(2,1,1)
plot(f,abs(fftshift(fft(samples))))
title("Original")
subplot(2,1,2)
plot(f,abs(fftshift(fft(shifted))))
title("Shifted")

figure
sgtitle("Signals frequency shifted")
subplot(2,1,1)
plot(abs(samples))
title("Original")
subplot(2,1,2)
plot(abs(shifted))
title("Shifted")
%% Samples are shifted on time
% delay_filter = zeros(500000,1);
% delay_filter(end) = 1;
% delayed = filter(delay_filter,1,samples);
delayed = delayseq(samples',5000);
correlation_matrix_delay = BatchProcessing(samples',delayed);
figure
sgtitle("Frequencies signals delayed")
subplot(2,1,1)
plot(f,abs(fftshift(fft(samples))))
title("Original")
subplot(2,1,2)
plot(f,abs(fftshift(fft(delayed))))
title("Delayed")

figure
sgtitle("Signals delayed")
subplot(2,1,1)
plot(samples)
title("Original")
subplot(2,1,2)
plot(delayed)
title("Delayed")

%% Shifting on time and frequency
shift = (1/length(samples))*50;
delay_filter = zeros(1,1);
delay_filter(end) = 1;
delayed_filtered = filter(delay_filter,1,samples);
delayed_filtered = delayed_filtered.*exp(-1i*2*pi*shift*n);
correlation_matrix_delay_shift = BatchProcessing(samples,delayed_filtered);

