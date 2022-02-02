function correlation_matrix = BatchProcessing(reference_batches,surveillance_batches)
% Function to calculate the CAF based on the batch processing algorithm
% this algorithm splits the reference and surveillance signals and assumes that the doppler frequency 
% shift within a block of the signal is negligible. Becasuse of that the cross anmibguity function can
% be calculated with the cross correlation of both signals and the fourier
% transform of the result.
global BATCH_SIZE
global PLOT
global Vmax
global Fs_used
global PROPAGATION_VELOCITY
global TIME_STEP


% The input must be two vectors with the reference signal and the
% surveillance signal
if size(reference_batches) ~= size(surveillance_batches)
    errID = 'myComponent:inputError';
    msgtext = 'Both arrays must be the same dimension';
    ME = MException(errID,msgtext);
    throw(ME)
end

correlation_matrix = [];
% The input array is reshaped to match the size of each batch analyzed
surveillance_batches = reshape(surveillance_batches,int64(BATCH_SIZE),[]);
reference_batches = reshape(reference_batches,BATCH_SIZE,[]);

% Each column of the surveillance_batches array represents a delay in time
[~,columns] = size(reference_batches);

for batch = 1:1:columns
    % Correlation of the reference signal and the surveillance signal
    % leading to the correlation 
    
    [cross_correlation,lags] = xcorr(surveillance_batches(:,batch),reference_batches(:,batch),BATCH_SIZE); 
    % There is no need to compute negative correlation, as there cannot be negative ranges, 
    % so half of the values are dropped
    cross_correlation = cross_correlation(ceil(length(cross_correlation)/2)+1:end,1);
    correlation_matrix = [correlation_matrix,cross_correlation];
end


% Calculating on the doppler domain
correlation_matrix = fftshift(abs(fft(correlation_matrix,512,2)),2); 


if PLOT
    Fs_analysis = Fs_used/BATCH_SIZE;
    range_max = PROPAGATION_VELOCITY*TIME_STEP;
    doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);
    range_axis= linspace(1,range_max,BATCH_SIZE);
    [X,Y] = meshgrid(range_axis,doppler_axis);
    figure
    surf(X,Y,abs(correlation_matrix.'),'EdgeColor','none')
    xlabel('Delay')
    ylabel('Doppler')
    zlabel('Correlation')
    title("CAF representation")
%     xlim([-Vmax Vmax]);
%     xticks([-Vmax:1/60:Vmax]);
end
end

