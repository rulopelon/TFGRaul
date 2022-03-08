function  Reciever(data)
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
% Coarse frequency synchronization
%coarse_corrected_signal = coarseFrequencySynchronization(data_resampled);

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
frame_synchronized= fineFrequencySynchronization(frame_synchronized);

% Symbol equalization
% Symbols are equalized independently
[~,symbols] = size(frame_synchronized);

%Signal for the reference channnel
symbols_equalization = zeros(NFFT,symbols);
%Signal for the surveillance channel
filtered_signal = zeros(NFFT,symbols);

%Signal for equalization
frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();

for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end

for i = 1:1:symbols
    symbol_equalize = frame_synchronized(:,i);
    symbol_equalize_fft = fftshift(fft(symbol_equalize));
    channel_estimation = nan(NFFT,1);
    for index = indexes
        channel_estimation(index+(NFFT-CARRIERS-1)/2) =symbol_equalize_fft(index+(NFFT-CARRIERS-1)/2)/frequency_reference(index+(NFFT-CARRIERS-1)/2);
    end
    %Query points for the interpolation

    channel_estimation_interpolated = fillmissing(channel_estimation,'linear');
   
    channel_estimation_interpolated(end-(NFFT-CARRIERS-1)/2 +1:end) = 0;
    channel_estimation_interpolated(1:(NFFT-CARRIERS-1)/2) =0;
    
    %i_interpolated = ifft(ifftshift(frequency_response));
    % The symbol is equalized
    symbol_equalized = fftshift(fft(symbol_equalize)).*channel_estimation_interpolated;
    
    
    %Processing to get two signals
    symbol_equalized =QAMDetection(symbol_equalized); 
    %Deleting clutter
    signal_substracted = symbol_equalize_fft -channel_estimation_interpolated(:,1).*symbol_equalized(:,1);

    filtered_signal(:,i) =  ifft(ifftshift(signal_substracted));
    symbols_equalization(:,i) = ifft(ifftshift(symbol_equalized));
    
end
% Prefix is added to the signal
reference_signal = [symbols_equalization(end-prefix_length+1:end,:);symbols_equalization(:,:)];
% Rearranging
reference_signal = reference_signal(:);
%Prefix is added to the signal
surveillance_signal = [filtered_signal(end-prefix_length+1:end,:);filtered_signal(:,:)];
surveillance_signal = surveillance_signal(:);

% Calculation of the range and doppler of the signal is performed

caf_matrix = BatchProcessing(reference_signal,surveillance_signal);
[doppler_columns,time_indexes] = max(caf_matrix);
[~,doppler_index]= max(doppler_columns);
time_index = time_indexes(doppler_index);
a = 1;

end

