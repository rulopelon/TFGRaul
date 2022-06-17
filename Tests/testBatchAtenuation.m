function testBatchAtenuation(direct_path,surveillance_path)
    load("variables.mat","L","M")

    % Data is resampled to match Fs = 9.14 Mhz
    direct_path_interpolated = interpolation(direct_path,L);
    % The signal is filtered
    reconstruction_filter_reciever = getFilter(M,L);
    % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
    direct_path_filtered = conv(direct_path_interpolated,reconstruction_filter_reciever,'same');
    %Decimation
    direct_path_processed = direct_path_filtered(1:M:length(direct_path_filtered));

    % Data is resampled to match Fs = 9.14 Mhz
    surveillance_path_interpolated = interpolation(surveillance_path,L);
    % The signal is filtered
    reconstruction_filter_reciever = getFilter(M,L);
    % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
    surveillance_path_filtered = conv(surveillance_path_interpolated,reconstruction_filter_reciever,'same');
    %Decimation
    surveillance_path_processed = surveillance_path_filtered(1:M:length(surveillance_path_filtered));


    [caf_matrix,doppler_axis] = BatchProcessing(direct_path_processed,surveillance_path_processed);
    plotResults(caf_matrix)

end

