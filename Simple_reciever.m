function signal_synchronized =  Simple_reciever(data)
% Reciever without symbol reconstruction, it recieves an OFDM signal and
% outputs the synchronized version of the signal


global PREFIX
global NFFT
global CARRIERS
global symbol_length

% % Data is resampled to match Fs = 9.14 Mhz
% data_interpolated = interpolation(data,L);
% % The signal is filtered
% reconstruction_filter_reciever = getFilter(M,L);
% % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
% data_filtered = conv(data_interpolated,reconstruction_filter_reciever,'same');
% %Decimation
% data_resampled = data_filtered(1:M:length(data_filtered));
data_resampled = data;
prefix_length = PREFIX*NFFT;
%Frame synchronism
index = symbolSynchronization(data_resampled);

% Previous values of the signal are deleted
signal_correlated = data_resampled(index-symbol_length+1:end);
% Number of symbols recieved
N_symbols = floor(length(signal_correlated)/symbol_length);


frame_synchronized = [];
for i = 1:1:N_symbols
    signal_append = signal_correlated(prefix_length+(prefix_length+NFFT)*(i-1)+1:symbol_length+(symbol_length)*(i-1));
    frame_synchronized = [frame_synchronized,signal_append.'];
end
frame_synchronized = frame_synchronized(:);
% Frequency synchronization
fft_frame_synchronized = fftshift(fft(frame_synchronized)); 

frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();
for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end
i_frequency_reference = ifft(ifftshift(frequency_reference));
frequency_reference = fftshift(fft(i_frequency_reference,length(fft_frame_synchronized)));

% Frequency deviation is calculated
[frequency_correlation,lags_freq] = xcorr(fft_frame_synchronized,frequency_reference);

% Getting the maximun value of the correlation
[~,index_max_freq] = max(frequency_correlation);
index_max_freq = lags_freq(index_max_freq);

% Translating discrete indexes to frequency
deltaF = 1/length(fft_frame_synchronized);
frequency_deviation = deltaF *index_max_freq;

% The signal is corrected in frequency
% Vector for the multiplication with the exponential
n = 0:1:length(fft_frame_synchronized)-1;
fft_frame_synchronized = fft_frame_synchronized.*exp(1i*2*pi*n*frequency_deviation);

% Prefix is added to the signal
signal_synchronized = zeros(N_symbols,(NFFT+prefix_length));

for i = 1:1:N_symbols-1
    symbol = fft_frame_synchronized(1+NFFT*i:NFFT*(i+1));
    signal_append =[symbol(end-prefix_length+1:end),symbol];
    signal_synchronized(i,:) = signal_append;
end
signal_synchronized =signal_synchronized(:);


end

