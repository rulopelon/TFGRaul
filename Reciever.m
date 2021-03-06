function  Reciever(data)
    % Reciever with channel equalization
    load("variables.mat", ...
        "PREFIX","NFFT","CARRIERS","L","M","Fs_used","PROPAGATION_VELOCITY")
    
    % Data is resampled to match Fs = 9.14 Mhz
    data_interpolated = interpolation(data,L);
    % The signal is filtered
    reconstruction_filter_reciever = getFilter(M,L);
    % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
    data_filtered = conv(data_interpolated,reconstruction_filter_reciever,'same');
    %data_filtered = filter(1,reconstruction_filter_reciever,data_interpolated);

    %Decimation
    data_resampled = data_filtered(1:M:length(data_filtered));
    prefix_length = PREFIX*NFFT;
    % Coarse frequency synchronization
    
    %Frame synchronism
    % Getting the indexes with the start of each symbol
    [frame_synchronized,~,modes] = symbolSynchronization(data_resampled);
    
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

%     for i = indexes
%         frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
%     end
    

    %Reference sequence for the scatter pilot equalization
    reference_sequence = getReferenceSequence();
    indexes_equalization = indexes+((NFFT-CARRIERS-1)/2);

    for i = 1:1:symbols
        symbol_equalize = frame_synchronized(:,i);
        symbol_equalize_fft = fftshift(fft(symbol_equalize));
        channel_estimation = zeros(NFFT,1);
    

%         % Scattered pilots vector
        scattered_pilots_vector =(0 + 3*rem(1,4) + 12*(0:CARRIERS));
        % Depending on the mode, the scattered pilots are on different
        % positions

        switch modes(i)
            case 1
                %Do nothing
            case 2
                % Add 3 to the scattered pilots vector
                scattered_pilots_vector =scattered_pilots_vector+3;
            case 3
                % Add 6 to the scattered pilots vector
                scattered_pilots_vector =scattered_pilots_vector+6;
            case 4
                % Add 9 to the scattered pilots vector
                scattered_pilots_vector =scattered_pilots_vector+9;
        end

        % Shifting the vector to match the DVB-T standard
        scattered_pilots_vector = scattered_pilots_vector+(NFFT-CARRIERS-1)/2;
        % Delete the values that exceed the last carrier index
        scattered_pilots_vector = scattered_pilots_vector(1:find(scattered_pilots_vector>CARRIERS+(NFFT-CARRIERS-1)/2));
        
        pilot = 1;
        frequency_reference = zeros(NFFT,1);
        for carrier= 1:1:CARRIERS+(NFFT-CARRIERS-1)/2
            if carrier == scattered_pilots_vector(pilot) 
                frequency_reference(carrier) = 4/3*2*(1/2-reference_sequence(carrier-(NFFT-CARRIERS-1)/2));
                pilot = pilot+1;
            end
        end
        
        for scatter_pilot = 1:1:length(scattered_pilots_vector)-1
            index_evaluate = scattered_pilots_vector(scatter_pilot);
            channel_estimation(index_evaluate) = symbol_equalize_fft(index_evaluate)/frequency_reference(index_evaluate);
        end
        
        %channel_estimation(indexes_equalization)=symbol_equalize_fft(indexes_equalization)./frequency_reference(indexes_equalization);
        channel_estimation_interpolated = interp1(scattered_pilots_vector(1:end-1),channel_estimation(scattered_pilots_vector(1:end-1),:),1:NFFT,'linear','extrap');
        channel_estimation_interpolated = channel_estimation_interpolated.';
        %Query points for the interpolation
    
        %channel_estimation_interpolated = fillmissing(channel_estimation,'linear');
        channel_estimation_interpolated(end+1-(NFFT-CARRIERS-1)/2:end) = 0;
        channel_estimation_interpolated(1:(NFFT-CARRIERS-1)/2-1) =0;
        %channel_estimation_interpolated(channel_estimation_interpolated==0) = 1;

        
        % Calculating the correction
        frequency_correction = 1./channel_estimation_interpolated;
        frequency_correction(end+1-(NFFT-CARRIERS-1)/2:end) = 0;
        frequency_correction(1:(NFFT-CARRIERS-1)/2-1) =0;
        %Substituting inf values with zeros
        inf_indexes = find(isinf(frequency_correction));
        frequency_correction(inf_indexes) = 0;
     
        % The symbol is equalized
        symbol_frequency_corrected = symbol_equalize_fft.*frequency_correction;
       
        
        %Processing to get two signals
        symbol_QAM_corrected =QAMDetectionV2(symbol_frequency_corrected,scattered_pilots_vector);
        pilot = 1;
        for carrier= 1:1:CARRIERS+(NFFT-CARRIERS-1)/2
            if carrier == scattered_pilots_vector(pilot) 
                symbol_QAM_corrected(carrier) = 4/3*2*(1/2-reference_sequence(carrier-(NFFT-CARRIERS-1)/2));
                pilot = pilot+1;
            end
       end
  
        
        %Deleting clutter
        signal_substracted = symbol_equalize_fft -channel_estimation_interpolated.*symbol_QAM_corrected;

        symbol_QAM_corrected(end+1-(NFFT-CARRIERS-1)/2:end) = 0;
        symbol_QAM_corrected(1:(NFFT-CARRIERS-1)/2-1) =0;

        signal_substracted(end+1-(NFFT-CARRIERS-1)/2:end) = 0;
        signal_substracted(1:(NFFT-CARRIERS-1)/2-1) =0;
        
        filtered_signal(:,i) =  ifft(ifftshift(signal_substracted));
        symbols_equalization(:,i) = ifft(ifftshift(symbol_QAM_corrected));
    end
    
    % Prefix is added to the signal
    reference_signal = [symbols_equalization(end-prefix_length+1:end,:);symbols_equalization(:,:)];
    % Rearranging
    reference_signal = reference_signal(:);
    %Prefix is added to the signal
    surveillance_signal = [filtered_signal(end-prefix_length+1:end,:);filtered_signal(:,:)];
    surveillance_signal = surveillance_signal(:);
    
    %Adding reference and surveillance signal 
    
    % Calculation of the range and doppler of the signal is performed
    [caf_matrix,doppler_axis] = BatchProcessing(reference_signal,surveillance_signal);

 
    %Calculating the maximum
    [doppler_columns,time_indexes] = max(caf_matrix);
    [~,doppler_index]= max(doppler_columns);
        
    bistatic_range = time_indexes(doppler_index);
    disp(bistatic_range)
    doppler_frequency = doppler_axis(doppler_index);
    
    
    %Showing the ellipse of the posible positions of the plane
    %Calculating the distance of each step
    base_line = 0;
    step_distance = (1/Fs_used)*PROPAGATION_VELOCITY;
    bistatic_range  = bistatic_range*step_distance;
    base_line = base_line *step_distance;
    
    plotResults(caf_matrix)
    
%     if base_line < bistatic_range
%         %Calculating ellipse parameters
%         a = bistatic_range/2;
%         b = sqrt((bistatic_range/2)^2-(base_line/2)^2);
%         x1  =0;
%         y1 = 0;
%         x2 = x1+base_line;
%         y2 = 0;
%         
%         t = linspace(0,2*pi);
%         X = a*cos(t);
%         Y = b*sin(t);
%         w = atan2(y2-y1,x2-x1);
%         x = (x1+x2)/2 + X*cos(w) - Y*sin(w);
%         y = (y1+y2)/2 + X*sin(w) + Y*cos(w);
%         
%         %Plotting the results
%         figure
%         plot(x,y)
%         hold on
%         plot(x1,y1,'o')
%         plot(x2,y2,'o')
%         axis equal
%         title("2D Biestatic estimation")
%         
%         %Plotting on 3d
%         [x,y,z] = ellipsoid(base_line/2,0,0,a,b,a);
%         z(1:int64(floor(length(z)))/2,:) = 0;
%         figure
%         surf(x,y,z,'FaceAlpha',0.5)
%         hold on
%         plot3(x1,y1,0,'ko','MarkerSize',3,'MarkerFaceColor','yellow','MarkerEdgeColor','yellow')
%         plot3(x2,y2,0,'ko','MarkerSize',3,'MarkerFaceColor','yellow','MarkerEdgeColor','yellow')
%         title("3D Biestatic estimation")
%     else
%         disp("There is an error on the estimation")
%          input("Waiting your input")
%     end


end