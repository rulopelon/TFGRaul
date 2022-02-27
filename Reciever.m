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
initial_index = indexes_synchro(1);
N_symbols = length(indexes_synchro);

artificial_indexes = zeros(1,N_symbols);
for i =0:1:N_symbols-1
    artificial_indexes(i+1) =(NFFT+prefix_length)*i+initial_index;
end
% Number of symbols recieved
disp(N_symbols)
frame_synchronized = zeros(NFFT+prefix_length,N_symbols);

i = 1;
for index= artificial_indexes
    frame_synchronized(:,i) = data_resampled(index-NFFT-prefix_length+1:index).';
    i = i+1;
end

frame_synchronized = frame_synchronized(prefix_length+1:end,:);
% Frequency correction
 %frame_synchronized= frequencySynchronization(frame_synchronized);

% Symbol equalization
% Symbols are equalized independently
%symbols_equalization = reshape(frame_synchronized,NFFT,[]);
[~,symbols] = size(frame_synchronized);


frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();

for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end

for i = 1:1:symbols
    symbol_equalize = frame_synchronized(:,i);
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
    symbol_equalized = conv(i_interpolated,symbol_equalize);
    symbol_equalized = fftshift(fft(symbol_equalize)).*interpolated;
    symbols_equalization(:,i) = ifft(ifftshift(symbol_equalized));
 
end
% Prefix is added to the signal
signal_synchronized = [symbols_equalization(end-prefix_length+1:end,:);symbols_equalization(:,:)];
signal_synchronized =signal_synchronized(:);

% Calculation of the range and doppler of the signal is performed

caf_matrix = BatchProcessing(signal_synchronized,data_resampled);
[doppler_columns,time_indexes] = max(caf_matrix);
[~,doppler_index]= max(doppler_columns);
time_index = time_indexes(doppler_index);
a = 1;

end

