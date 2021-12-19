function correlation_matrix = blockProcessing(reference_batches,surveillance_batches)
% Function to calculate the CAF based on the batch processing algorithm
% this algorithm splits the reference and surveillance signals and assumes that the doppler frequency 
% shift within a block of the signal is negligible. Becasuse of that the cross anmibguity function can
% be calculated with the cross correlation of both signals and the fourier
% transform of the result.
global BATCH_SIZE
global NFFT_BATCH_SIZE
global delay_detected
global doppler_detected

% The input must be two vectors with the reference signal and the
% surveillance signal
if size(refrerence_batches) ~= size(surveillance_batches)
    errID = 'myComponent:inputError';
    msgtext = 'Both arrays must be the same dimension';
    ME = MException(errID,msgtext);
    throw(ME)
end

correlation_matrix = [];
% The input array is reshaped to match the size of each batch analyzed
surveillance_batches = reshape(surveillance_batches,BATCH_SIZE,[]);
reference_batches = reshape(reference_batches,BATCH_SIZE,[]);

% Each column of the surveillance_batches array represents a delay in time

for batch = 1:1:BATCH_SIZE
    % Correlation of the reference signal and the surveillance signal
    % leading to the correlation 
    [cross_correlation,lags] = xcorr(surveillance_batches(:,batch),reference_batches(:,batch),BATCH_SIZE); 
    % There is no need to compute negative correlation, as there cannot be negative ranges, 
    % so half of the values are dropped
    cross_correlation = cross_correlation(BATCH_SIZE+1:end,1);
    correlation_matrix = [correlation_matrix,cross_correlation];
    
end
% Calculating on the doppler domain
correlation_matrix = fft(correlation_matrix,NFFT_BATCH_SIZE,2); 


for i = 1:1:BATCH_SIZE
    % Indexing on the delay dimension 
    for j = 1:1:NFFT_BATCH_SIZE
        % Indexing on the doppler dimension
        if correlation_matrix(i,j) >= threshold
            %TODO: change the way of outputting the daly and doppler
            %result
            % A target has been detected
            doppler_detected = j;
            delay_detected = i;
        end
    end
end
if PLOT
   
    figure
    surf(real(correlation_matrix),'EdgeColor','none')
    xlabel('Doppler')
    ylabel('Delay')
    zlabel('Correlation')
    title("CAF representation")
end
end

