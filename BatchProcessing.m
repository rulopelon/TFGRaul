function [correlation_matrix,doppler_axis] = BatchProcessing(reference_batches,surveillance_batches)
    % Function to calculate the CAF based on the batch processing algorithm
    % this algorithm splits the reference and surveillance signals and assumes that the doppler frequency 
    % shift within a block of the signal is negligible. Becasuse of that the cross anmibguity function can
    % be calculated with the cross correlation of both signals and the fourier
    % transform of the result.
    load("variables.mat","BATCH_SIZE","Fs_used")
  
    % The signal is adapted to have the desired length
    surveillance_batches = surveillance_batches(1:floor(length(surveillance_batches)/BATCH_SIZE)*BATCH_SIZE);
    reference_batches = reference_batches(1:floor(length(reference_batches)/BATCH_SIZE)*BATCH_SIZE);
   
    % The input array is reshaped to match the size of each batch analyzed
    surveillance_batches = reshape(surveillance_batches,int64(BATCH_SIZE),[]);
    reference_batches = reshape(reference_batches,BATCH_SIZE,[]);
    
    % Each column of the surveillance_batches array represents a delay in time
    [~,columns] = size(reference_batches);
    % Prealocating the matrix
    correlation_matrix = zeros(BATCH_SIZE,columns);
    for batch = 1:1:columns
        % Correlation of the reference signal and the surveillance signal
        % leading to the correlation 
        
        % There is no need to compute negative correlation, as there cannot be negative ranges, 
        % so half of the values are dropped        
        cross_correlation = fft(surveillance_batches(:,batch),BATCH_SIZE).*fft(conj(flip(reference_batches(:,batch))),BATCH_SIZE);
        cross_correlation_ifft = ifft(cross_correlation,BATCH_SIZE);
        correlation_matrix(:,batch) =cross_correlation_ifft';
    end
    
    % Calculating on the doppler domain
    correlation_matrix = abs(fftshift(fft(correlation_matrix,512,2),2));
    % Deleting the negative delays correlation, as the signal will only be present
    % with positive delays
    %correlation_matrix = correlation_matrix(1:length(cross_correlation_ifft)/2,:);
    
    %Deleting random peaks at delay 0
    correlation_matrix(1:4,:) = 0;
    %Deleting random peaks at the last index
    correlation_matrix(end-4:end,1) = 0;

    %Calculating the axis for the frequency shift representation
    Fs_analysis = Fs_used/BATCH_SIZE;
    doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);

    
   
end

