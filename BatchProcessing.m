function [correlation_matrix,doppler_axis] = BatchProcessing(reference_batches,surveillance_batches)
    % Function to calculate the CAF based on the batch processing algorithm
    % this algorithm splits the reference and surveillance signals and assumes that the doppler frequency 
    % shift within a block of the signal is negligible. Becasuse of that the cross anmibguity function can
    % be calculated with the cross correlation of both signals and the fourier
    % transform of the result.
    load("variables.mat","PLOT","BATCH_SIZE","Fs_used")
    PLOT = true;
    % The signal is adapted to have the desired length
%     surveillance_batches = [surveillance_batches;zeros(ceil(length(surveillance_batches)/BATCH_SIZE)*BATCH_SIZE-length(surveillance_batches),1)];
%     reference_batches = [reference_batches;zeros(length(surveillance_batches)-length(reference_batches),1)];
    surveillance_batches = surveillance_batches(1:floor(length(surveillance_batches)/BATCH_SIZE)*BATCH_SIZE);
    reference_batches = reference_batches(1:floor(length(reference_batches)/BATCH_SIZE)*BATCH_SIZE);

    % The input must be two vectors with the reference signal and the
    % surveillance signal
%     if size(reference_batches) ~= size(surveillance_batches)
%         % The reference array may be smaller, so it is padded with zeros
%         reference_batches = [reference_batches,zeros(length(surveillance_batches)-length(reference_batches),1)];
%     end
    
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
        index_drop = find(lags==0);
        cross_correlation = cross_correlation(index_drop+1:end,1);
        correlation_matrix = [correlation_matrix,cross_correlation];
    end
    
    
    % Calculating on the doppler domain
    correlation_matrix = abs(fftshift(fft(correlation_matrix,512,2),2)); 
    %Calculating the axis for the frequency shift representation
    Fs_analysis = Fs_used/BATCH_SIZE;
    doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);

    
    if PLOT
        Fs_analysis = Fs_used/BATCH_SIZE;
        doppler_axis = linspace(-0.5*Fs_analysis,0.5*Fs_analysis,512);
        range_axis= 1:1:BATCH_SIZE;
        [X,Y] = meshgrid(range_axis,doppler_axis);
        f = figure;
        surf(X,Y,abs(correlation_matrix.'),'EdgeColor','none')
        xlabel('Delay')
        ylabel('Doppler')
        zlabel('Correlation')
        ax = gca;
        ax.Color = 'white';
        title("CAF representation")
%         nombre = input("Introduzca el nombre de la figura");
%         guardaFiguraPaper(nombre,f,ax,'-djpeg',0)
    end
end

