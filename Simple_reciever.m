function  Simple_reciever(data)

global signal_buffer
global reference_buffer
global surveillance_buffer 
global BATCH_SIZE
global PREFIX
global NFFT
global CARRIERS
global symbol_length
global M
global L

% Data is resampled to match Fs = 9.14 Mhz
data_interpolated = interpolation(data,L);
% The signal is filtered
reconstruction_filter_reciever = getFilter(M,L);
% Filtering the signal to eliminate not wanted frequencies caused by the interpolation
data_filtered = conv(data_interpolated,reconstruction_filter_reciever,'same');
%Decimation
data_resampled = data_filtered(1:M:length(data_filtered));

signal_buffer = [data_resampled,signal_buffer];
% The signal is divided on reference and surveillance
reference_signal = [];
surveillance_signal =[];
prefix_length = PREFIX*NFFT;
%Frame synchronism
[correlation,~] = xcorr(reference_signal,reference_signal);
% Only positive lags are used
correlation = correlation(ceil((length(correlation)/2))+1:end);
% Getting the maximun value of the correlation
[~,index_max] = max(correlation);
% Previous values of the signal are deleted
signal_correlated = reference_signal(index_max+1:end);

% The prefix is eliminated
% Number of symbols recieved
N_symbols = length(signal_correlated)/symbol_length;

frame_synchronized = [];
for i = 1:1:N_symbols
    
    signal_append = signal_correlated(prefix_length+(prefix_length+NFFT)*(i-1)+1:symbol_length+(symbol_length)*(i-1));
    frame_synchronized = [frame_synchronized,signal_append];
end
% Frequency synchronization
fft_frame_synchronized = fftshift(fft(frame_synchronized)); 

frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();
for i = indexes
    frequency_reference(i+(NFFT-CARRIERS)/2,1) = pilot_values(i+1);
end

% Frequency deviation is calculated
[frequency_correlation,~] = xcorr(fft_frame_synchronized,frequency_reference);
% Only positive lags are used
frequency_correlation = frequency_correlation(length(fft_frame_synchronized)+1:end); % Zero lag is considered
% Getting the maximun value of the correlation
[~,index_max_freq] = max(frequency_correlation);

% Translating discrete indexes to frequency
deltaF = 1/NFFT;
frequency_deviation = deltaF *index_mad_freq;
% The signal is corrected in frequency
% Vector for the multiplication with the exponential
n = 0:1:length(fft_frame_synchronized)-1;
fft_frame_synchronized = fft_frame_synchronized.*exp(-1i*2*pi*n*frequency_deviation);

% Prefix is added to the signal
signal_synchronized = [];
Len_prefix = NFFT+PREFIX;
for i = 1:1:length(fft_frame_synchronized)/NFFT
    symbol = fft_frame_synchronized(1+NFFT*i:NFFT*(i+1));
    signal_append =[symbol(end-Len_prefix+1:end,1),symbol];
    signal_synchronized = [signal_append,signal_synchronized];
end

%Equalization

%Data is appended to the stream
reference_buffer = [reference_buffer,reference_signal];
surveillance_buffer = [surveillance_buffer,surveillance_signal];

% if length(signal_buffer) >= BATCH_SIZE*NUMBER_BATCHES
%     % Forcing the numerb of samples to be a multiplier of the number of
%     % batches
%     surveillance_analyze =[];
%     reference_analyse = [];
%     
%     if mod(length(signal_buffer),BATCH_SIZE) ~=0
%         n_batches = fix(length(signal_buffer),BATCH_SIZE); % The number of full batches (integer) to use
%         reference_analyse = reference_buffer(1:(n_batches*BATCH_SIZE)+1,:);
%         surveillance_analyze = reference_buffer(1:(n_batches*BATCH_SIZE)+1,:); 
%         
%         % Buffers are updated
%         signal_buffer = signal_buffer((n_batches*BATCH_SIZE)+2:length(surveillance_buffer));
%         reference_buffer = reference_buffer((n_batches*BATCH_SIZE)+2:length(surveillance_buffer));
%         surveillance_buffer = surveillance_buffer((n_batches*BATCH_SIZE)+2:length(surveillance_buffer),1);
%     else
%         reference_analyse = reference_buffer;
%         surveillance_analyze = surveillance_buffer;
%         %Buffers are emptied
%         signal_buffer = [];
%         reference_buffer = [];
%         surveillance_buffer = [];
%     end 
%     % The signal is analysed and targets are detected
%     BatchProcessing(reference_analyse,surveillance_analyze);
%     
%     
% end
end

