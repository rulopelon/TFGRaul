function signal_synchronized =  Simple_reciever(data)
% Reciever without symbol reconstruction, it recieves an OFDM signal and
% outputs the synchronized version of the signal


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


prefix_length = PREFIX*NFFT;
%Frame synchronism
[correlation,lags] = xcorr(data_resampled,data_resampled);
% Only positive lags are used
correlation = correlation(ceil((length(correlation)/2))+1:end);
% Getting the maximun value of the correlation
[~,index_max] = max(correlation);
% Previous values of the signal are deleted
signal_correlated = data_resampled(index_max+1:end);

% The prefix is eliminated
% Number of symbols recieved
N_symbols = length(signal_correlated)/symbol_length;

frame_synchronized = [];
for i = 1:1:N_symbols
    signal_append = signal_correlated(prefix_length+(prefix_length+NFFT)*(i-1)+1:symbol_length+(symbol_length)*(i-1));
    frame_synchronized = [frame_synchronized,signal_append'];
end
% Frequency synchronization
fft_frame_synchronized = fftshift(fft(frame_synchronized)); 

frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();
for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end

% Frequency deviation is calculated
[frequency_correlation,lags_freq] = xcorr(fft_frame_synchronized,frequency_reference*64);

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
signal_synchronized = [];
Len_prefix = NFFT+PREFIX;
for i = 1:1:length(fft_frame_synchronized)/NFFT
    symbol = fft_frame_synchronized(1+NFFT*i:NFFT*(i+1));
    signal_append =[symbol(end-Len_prefix+1:end,1),symbol];
    signal_synchronized = [signal_append,signal_synchronized];
end



end

