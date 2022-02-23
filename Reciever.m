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
% Getting the indexes with the start of each symbol
indexes_synchro = symbolSynchronization(data_resampled);
% Number of symbols recieved
N_symbols = length(indexes_synchro);
frame_synchronized = zeros(NFFT,N_symbols);

i = 1;
for index= indexes_synchro
    frame_synchronized(:,i) = data_resampled(index-NFFT+1:index).';
    i = i+1;
end
% Frequency correction
frequencySynchronization(frame_synchronized);

% Symbol equalization
% Symbols are equalized independently
symbols_equalization = reshape(frame_synchronized,NFFT,[]);
[~,symbols] = size(symbols_equalization);


frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();

for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end

for i = 1:1:symbols
    symbol_equalize = symbols_equalization(:,i);
    symbol_equalize_fft = fftshift(fft(symbol_equalize));
    frequency_response_plot = nan(NFFT,1);
    for index = indexes
        frequency_response_plot(index+(NFFT-CARRIERS-1)/2) =frequency_reference(index+(NFFT-CARRIERS-1)/2)/symbol_equalize_fft(index+(NFFT-CARRIERS-1)/2);
    end
    %Query points for the interpolation

    interpolated = fillmissing(frequency_response_plot,'linear');
   
    interpolated(end-(NFFT-CARRIERS-1)/2 +1:end) = 0;
    interpolated(1:(NFFT-CARRIERS-1)/2) =0;

    i_interpolated = ifft(ifftshift(interpolated));
    % The symbol is equalized
    symbol_equalized = conv(symbol_equalize,i_interpolated,'same');
    symbols_equalization(:,i) = symbol_equalized;
 
end
% Prefix is added to the signal
signal_synchronized = zeros(N_symbols,(NFFT+prefix_length));

signal_synchronized = [symbols_equalization(end-prefix_length+1:end,:);symbols_equalization(:,:)];
signal_synchronized =signal_synchronized(:);

% Calculation of the range and doppler of the signal is performed

caf_matrix = BatchProcessing(signal_synchronized,data_resampled);


end

