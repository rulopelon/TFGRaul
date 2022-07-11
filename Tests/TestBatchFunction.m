%% Code to test the BlockProcessing function
% Inizialization
clear, clc, close all force;
load("variables.mat","L","M","Samples_iteration","Nsym_simulation","Fs_used")


Fs = 1e6;       % just for quicker testing

 [Ofdm_signal ,~]= OFDMModV3(Nsym_simulation);
 samples =Ofdm_signal;


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
samples = data_resampled;
%samples = samples(end-int64(Samples_iteration)+1:end);
n = 0:1:length(samples)-1;
n = n';
shift = -200; % In hertz
shift = shift/Fs_used;

%% Samples are shifted on frequency 
delay_filter1 = zeros(5,1);
delay_filter1(end) = 1;

delayed = filter(delay_filter1,1,samples);
shifted = delayed.*exp(-1i*2*pi*shift*n);
% Samples are analyzed
[correlation_matrix_doppler,~]= BatchProcessing(samples,shifted);
plotResults(correlation_matrix_doppler)


%% Samples are shifted on time

delayed = filter(delay_filter,1,samples);
[correlation_matrix_delay,~] = BatchProcessing(samples,delayed);
plotResults(correlation_matrix_delay)



%% Shifting on time and frequency

delayed_filtered = filter(delay_filter,1,samples);
delayed_filtered = delayed_filtered.*exp(-1i*2*pi*shift*n);
[correlation_matrix_delay_shift,~] = BatchProcessing(samples,delayed_filtered);
plotResults(correlation_matrix_delay_shift)

