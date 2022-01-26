% Code to test the BlockProcessing function
% Inizialization
clear, clc, close all force;
parameters;
global M
global L
global Samples_iteration
% Forcing the function to plot the results
PLOT = true;

Fs = 1e6;       % just for quicker testing

samples = OFDMModV2(Nsym);


% Data is resampled to match Fs = 9.14 Mhz
data_interpolated = interpolation(samples,L);
% The signal is filtered
reconstruction_filter_reciever = getFilter(M,L);
% Filtering the signal to eliminate not wanted frequencies caused by the interpolation
data_filtered = conv(data_interpolated,reconstruction_filter_reciever,'same');
%Decimation
data_resampled = data_filtered(1:M:length(data_filtered));

delay_filter = zeros(4000,1);
delay_filter(end) = 1;

samples = samples(end-int64(Samples_iteration)+1:end);
n = 0:1:length(samples)-1;
shift = (1/length(samples))*50;

%% Samples are shifted on frequency 


shifted = samples.*exp(-1i*2*pi*shift*n);
% Samples are analyzed
correlation_matrix_doppler= BatchProcessing(samples,shifted);

%% Samples are shifted on time

delayed = filter(delay_filter,1,samples);
correlation_matrix_delay = BatchProcessing(samples,delayed);

%% Shifting on time and frequency

delayed_filtered = filter(delay_filter,1,samples);
delayed_filtered = delayed_filtered.*exp(-1i*2*pi*shift*n);
correlation_matrix_delay_shift = BatchProcessing(samples,delayed_filtered);

