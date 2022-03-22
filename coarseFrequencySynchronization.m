function signal_synchronized = coarseFrequencySynchronization(data)
    load('variables.mat','NFFT','CARRIERS')
    frequency_reference = zeros(NFFT,1);
    [indexes, pilot_values]=getContinuousPilots();
    
    for i = indexes
        frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
    end
    % The signal frequency_reference is resized to match the size of the
    % input signal
    i_frequency_reference =ifft(ifftshift(frequency_reference));
    frequency_reference = fftshift(fft(i_frequency_reference,length(data)));

    % The deviation is calculated
    signal_synchronize_fft = fftshift(fft(data));
    [correlation,lags]=xcorr(signal_synchronize_fft,frequency_reference);
    [~,index]= max(correlation);
   
    % Frequency correction
    n = 0:1:length(signal_synchronize_fft)-1;
    deviation = lags(index)/length(data);
    signal_synchronized = data.*exp(-1i*2*pi*deviation*n');
    [correlation,lags]=xcorr(fftshift(fft(signal_synchronized)),frequency_reference);
    a = 1;
end

