function correlation_matrix = blockProcessing(reference_batches,surveillance_batches)
% Function to calculate the CAF based on the batch processing algorithm
% this algorithm splits the reference and surveillance signals and assumes that the doppler frequency shift whitin a block of
% signal is negligible. Becasuse of that the cross anmibguity function can
% be calculated with the cross correlation of both signals and the fourier
% transform of the result.

% Samples of time delay 
n_samples = length(reference_batches(:,1));
NFFT = length(reference_batches); % The size of the fourier transform isd the number of batches that are used
correlation_matrix = [];
PLOT = true;
for batch = 1:1:length(reference_batches)
    % Correlation of the reference signal and the surveillance signal
    % leading to the correlation 
    [cross_correlation,lags] = xcorr(surveillance_batches(batch,:),reference_batches(batch,:),n_samples); 
    % There is no need to compute negative correlation, as there cannot be negative ranges, 
    % so half of the values are dropped
    cross_correlation = cross_correlation(1,n_samples+1:end);
    correlation_matrix = [correlation_matrix;cross_correlation];
    
end
% Calculating on the doppler domain
correlation_matrix = fft(correlation_matrix,NFFT); 

if PLOT
   
    figure
    surf(real(correlation_matrix),'EdgeColor','none')
    xlabel('Range')
    ylabel('Velocity')
    zlabel('Correlation')
    title("CAF representation")
end
end

