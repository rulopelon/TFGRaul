function  signal_synchronized = Reciever(data)
hola = data;
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
data_resampled = hola;
prefix_length = PREFIX*NFFT;
%Frame synchronism
index = symbolSynchronization(hola);
index = 8548;
% Previous values of the signal are deleted
% Number of symbols recieved
N_symbols = floor(length(data_resampled)/symbol_length);
data_resampled = data_resampled(index+1-symbol_length:end);

frame_synchronized = reshape(data_resampled,NFFT+prefix_length,[]);
frame_synchronized = frame_synchronized(prefix_length+1:end,:);
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

%     figure
%     plot(abs(symbol_equalize_fft))
%     hold on 
%     plot(abs(fftshift(fft(symbol_equalized))),'o')
%     legend("Original","Ecualizado")
%     
%     figure
%     plot(abs(frequency_response_plot),'*')
%     hold on
%     plot(abs(interpolated),'o')
%     legend('original','interpolated')
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

