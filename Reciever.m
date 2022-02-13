function  Reciever(data)
% Reciever with channel equalization
load("variables.mat","signal_buffer","reference_buffer","BATCH_SIZE", ...
    "PREFIX","NFFT","CARRIERS","symbol_length","L","M")

% Data is resampled to match Fs = 9.14 Mhz
data_interpolated = interpolation(data,L);
% The signal is filtered
reconstruction_filter_reciever = getFilter(M,L);
% Filtering the signal to eliminate not wanted frequencies caused by the interpolation
data_filtered = conv(data_interpolated,reconstruction_filter_reciever,'same');
%Decimation
data_resampled = data_filtered(1:M:length(data_filtered));


prefix_length = PREFIX*NFFT;
%Frame synchronism
index = symbolSynchronization(data_resampled);

% Previous values of the signal are deleted
signal_correlated = data_resampled(index-symbol_length+1:end);
% Number of symbols recieved
N_symbols = floor(length(signal_correlated)/symbol_length);

% The post values not used are eliminated
signal_correlated = signal_correlated(1:N_symbols*symbol_length);

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

% Now that the symbol is synchronized, equelization is performed to
% eliminate the efect of the channel
% The fft_frame_synchronized is compared with reference pilot
attenuation_values = zeros(length(indexes));
j = 1;
for i = indexes
    attenuation_values(j) = fft_frame_synchronized(i+(NFFT-CARRIERS)/2,1)/frequency_reference(i+(NFFT-CARRIERS)/2,1);
    j = j+1;
end
attenuation = mean(attenuation_values);
fft_frame_synchronized = fft_frame_synchronized.*(1/attenuation);

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


end

