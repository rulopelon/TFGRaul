function  frame_corrected = frequencySynchronization(frame)
load("variables.mat","NFFT","CARRIERS")


frame = reshape(frame,NFFT,[]);
[~,symbols] = size(frame);
frame_corrected = zeros(NFFT,symbols);

frequency_reference = zeros(NFFT,1);
[indexes, pilot_values]=getContinuousPilots();

for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end

for symbol = 1:1:symbols
    frame_synchronize = frame(:,symbol);
    frame_synchronize_fft = fftshift(fft(frame_synchronize));
    [correlation,lags]=xcorr(frame_synchronize_fft,frequency_reference);
    [~,index]= max(correlation);
   
    % Frequency correction
    n = 0:1:length(frame_synchronize)-1;
    deviation = lags(index)/length(frame_synchronize);
    frame_synchronize = frame_synchronize.*exp(-1i*deviation*n');
    frame_corrected(:,symbol) =frame_synchronize; 

end




end

