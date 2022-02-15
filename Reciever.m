function  signal_synchronized = Reciever(data)
% Reciever with channel equalization
load("variables.mat", ...
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
signal_correlated = data_resampled(index-symbol_length:end);
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
frequency_reference_adapted = fftshift(fft(i_frequency_reference,length(fft_frame_synchronized)));

% Frequency deviation is calculated
[frequency_correlation,lags_freq] = xcorr(fft_frame_synchronized,frequency_reference_adapted);

% Getting the maximun value of the correlation
[~,index_max_freq] = max(frequency_correlation);
index_max_freq = lags_freq(index_max_freq);

% Translating discrete indexes to frequency
deltaF = 1/length(fft_frame_synchronized);
frequency_deviation = deltaF *index_max_freq;

% The signal is corrected in frequency
% Vector for the multiplication with the exponential
n = 0:1:length(fft_frame_synchronized)-1;
frame_synchronized = ifft(ifftshift(fft_frame_synchronized));
frame_synchronized = frame_synchronized.*exp(-1i*2*pi*n.'*frequency_deviation);

% Symbol equalization
% Symbols are equalized independently
symbols_equalization = reshape(frame_synchronized,NFFT,[]);
[~,symbols] = size(symbols_equalization);
xq = 1:1:NFFT;

for i = 1:1:symbols
    symbol_equalize = symbols_equalization(:,i);
    symbol_equalize_fft = fftshift(fft(symbol_equalize));
    frequency_response = zeros(length(indexes),1);
    frequency_response_plot = zeros(NFFT,1);
    j = 0;
    for index = indexes
        frequency_response(j+1) = frequency_reference(index+(NFFT-CARRIERS-1)/2)/symbol_equalize_fft(index+(NFFT-CARRIERS-1)/2);
        frequency_response_plot(index+(NFFT-CARRIERS-1)/2) =frequency_reference(index+(NFFT-CARRIERS-1)/2)/symbol_equalize_fft(index+(NFFT-CARRIERS-1)/2);
        j = j+1;
        xq(index+1) = [];
    end
    %Query points for the interpolation
    interpolated = interp1(indexes+1,frequency_response,xq,'nearest');
    
    j = 0;
    for index = indexes
       interpolated = [interpolated(1:index-1+(NFFT-CARRIERS-1)/2),frequency_response(j+1),interpolated(index+(NFFT-CARRIERS-1)/2:end)];
        j = j+1;
    end
    interpolated(end-(NFFT-CARRIERS-1)/2 +1:end) = 0;
    interpolated(1:(NFFT-CARRIERS-1)/2) =0;

    i_interpolated = ifft(ifftshift(interpolated));
    % The symbol is equalized
    symbol_equalized = conv(symbol_equalize,i_interpolated);

    symbols_equalization(:,i) = symbol_equalized;

    figure
    plot(abs(symbol_equalize_fft))
    hold on 
    plot(fftshift(fft(abs(symbol_equalized))))
    legend("Original","Ecualizado")
    
    figure
    plot(abs(frequency_response_plot),'*')
    hold on
    plot(abs(interpolated),'o')
    legend('original','interpolated')
    %Frequency response is interpolated
    
end
% Prefix is added to the signal
signal_synchronized = zeros(N_symbols,(NFFT+prefix_length));

for i = 1:1:symbols
    symbol = symbols_equalization(:,i);
    signal_append =[symbol(end-prefix_length+1:end);symbol];
    signal_synchronized(i,:) = signal_append;
end
signal_synchronized =signal_synchronized(:);



end

