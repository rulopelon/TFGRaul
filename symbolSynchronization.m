function [frame_synchronized,indexes_synchronization,modes]  = symbolSynchronization(data_input)
    load("variables.mat","prefix_length","NFFT","CARRIERS","symbol_length")
    %% Time synchronization
   
    %Calculating alfa cp
    y = [data_input; zeros(NFFT,1)].*conj([zeros(NFFT,1); data_input]);
    % Add
    estimator= conv(y.',ones(prefix_length,1));
    
    threshold = max(estimator)*0.5;

    indexes_search = find(abs(estimator)>threshold);
    % Indexes are divided on "steps"
    i = 1;
    index_search = 1;
    indexes_synchronization = [];
    while i<= length(indexes_search)
        first_index = indexes_search(i);
        % A line with slope one is created
        estimation = first_index:1:symbol_length+first_index;
        found = false;
        % Searching for the value that starts the step
        j = 0;
        while found == false && j+index_search<= length(indexes_search)
            if indexes_search(j+index_search) > estimation(j+1)+80
                found = true;
                last_index = j+first_index-1;
                index_search = j+index_search;        
            end
            j =j+1;
        end
        i = index_search;
        step = estimator(first_index:last_index);
        [~,index] = max(step);
        indexes_synchronization = [indexes_synchronization,index+first_index-1];
       
        if j+index_search>= length(indexes_search)
            step = estimator(first_index:end);
            [~,index] = max(step);
             indexes_synchronization = [indexes_synchronization,index+first_index-1];
            break;
        end
    end

    
    %% Frequency synchronization
    frequency_estimator =-(1/(2*pi)).*angle(estimator);
    %% Symbol splitting
    initial_index = indexes_synchronization(1);
    initial_index = 9521;
    disp(initial_index)
    N_symbols = ceil(length(data_input)/symbol_length);
    
    artificial_indexes = zeros(1,N_symbols);
    for i =0:1:N_symbols-1
        artificial_indexes(i+1) =(NFFT+prefix_length)*i+initial_index;
        
    end
    diferences = zeros(N_symbols,1);
    %Reference signal for equalization
    frequency_reference = zeros(NFFT,1);
    [indexes_equalization, pilot_values]=getContinuousPilots();

    
    for i = indexes_equalization
        frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
    end

    % Number of symbols recieved
    frame_synchronized = zeros(NFFT,N_symbols);
    
    i = 1;
    % Modes for the scatter pilots
    modes = zeros(N_symbols,1);
    j = 1;
    
    %Reference sequence for the scatter pilot equalization
    reference_sequence = getReferenceSequence();
    
    %Iterating all the symbols
    indexes_equalization = indexes_equalization+((NFFT-CARRIERS-1)/2);

    for index_synchronization= indexes_synchronization
        if index_synchronization-NFFT-prefix_length+1<=length(data_input)-NFFT-prefix_length && index_synchronization-NFFT-prefix_length >0
            frame = data_input(index_synchronization-NFFT+1:index_synchronization,1);
            
            %Frequency deviation estimation
            frequency_deviation = frequency_estimator(index_synchronization/length(NFFT));

            % Coarse frequency deviation correction
            n =0:1:length(frame)-1;
            %frame = frame.*exp(-1i*2*pi*frequency_deviation*n.');
            
            % Transforming to the frequency domain
            frame = fftshift(fft(frame,NFFT));

            % Performing scattered pilot detection as in timing
            % synchronization for DVB-T Systems
            k_values = [0,1,2,3];
            correlations  = zeros(length(k_values),1);
            i_values_vector = 1:1:(NFFT/12)-1;
            for k= k_values
                indexed_positions  = 3*k+12*i_values_vector+(NFFT-CARRIERS-1)/2;
                indexed_positions = indexed_positions(1:find(indexed_positions>NFFT)-1);
                correlations(k+1) = sum(frame(indexed_positions).*conj(frame(indexed_positions)));
            end
            [value,mode] = max(correlations);
            
            % Saving the mode
            mode = mode-1;
            if mode == 0
                mode = 4;
            end
            modes(i) = j;
            mode = j;
            
            % Knowing the mode of the scattered pilots, fine symbol
            % correction can be performed

            % Scattered pilots vector
            scattered_pilots_vector =(0 + 3*rem(1,4) + 12*(0:CARRIERS));
            % Depending on the mode, the scattered pilots are on different
            % positions
            
            switch mode
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

            % Fine symbol synchronization based on the channel response
            channel_estimation = nan(NFFT,1);

%             %Signal for equalization
%             frequency_reference = zeros(NFFT,1);
% 
%             pilot = 1;
%             for carrier= 1:1:CARRIERS+(NFFT-CARRIERS-1)/2
%                 if carrier == scattered_pilots_vector(pilot) 
%                     frequency_reference(carrier) = 4/3*2*(1/2-reference_sequence(carrier-(NFFT-CARRIERS-1)/2));
%                     pilot = pilot+1;
%                 end
%             end
          % Deleting CARRIERS not used
            frequency_reference(end-(NFFT-CARRIERS-1)/2 +1:end,:) = 0;
            frequency_reference(1:(NFFT-CARRIERS-1)/2) =0;

%             for index = indexes_equalization
%                 index_evaluate = index+((NFFT-CARRIERS-1)/2);
%                 channel_estimation(index_evaluate) =frame(index_evaluate)/frequency_reference(index_evaluate);
%             end
            channel_estimation(indexes_equalization)=frame(indexes_equalization)./frequency_reference(indexes_equalization);

   

%             for scatter_pilot = 1:1:length(scattered_pilots_vector)-1
%                 index_evaluate = scattered_pilots_vector(scatter_pilot);
%                 channel_estimation(index_evaluate) = frame(index_evaluate)/frequency_reference(index_evaluate);
%             end

            %Query points for the interpolation
            channel_estimation_interpolated = interp1(indexes_equalization,channel_estimation(indexes_equalization,:),1:NFFT,'linear','extrap');
            %channel_estimation_interpolated = fillmissing(channel_estimation,'linear');
            channel_estimation_interpolated(end+1-(NFFT-CARRIERS-1)/2:end) = 0;
            channel_estimation_interpolated(1:(NFFT-CARRIERS-1)/2-1) =0;
  
            %Substituting inf values with zeros
            inf_indexes = find(isinf(channel_estimation_interpolated));
            channel_estimation_interpolated(inf_indexes) = 0;

            impulse_response= ifft(ifftshift(channel_estimation_interpolated));
            %b = fft(a);
            
            %shift = mean(-1*diff(unwrap(angle(b(1:round(NFFT))))*NFFT/(2*pi))); 
            [~,shift] = max(abs(impulse_response));
            if shift>=NFFT/2
                shift = shift-NFFT;
            end
            %shift =0;
            % Calculating the index
            fine_index = round(index_synchronization+shift);
            diferences(i) = artificial_indexes(i)-fine_index;
            final_frame = data_input(fine_index-NFFT+1:fine_index,1);
            %Frequency deviation estimation
            final_frequency_deviation = frequency_estimator(fine_index)/length(final_frame);
            %Frequency deviation correction
            n =0:1:length(final_frame)-1;
            %final_frame = final_frame.*exp(-1i*2*pi*final_frequency_deviation*n.');
            
            % Adding the synchronized frame to the output
            frame_synchronized(:,i) = final_frame;
        
          
            i = i+1;
            if j == 4
                j=1;
            else
                j = j+1;
            end

        end
    end
    
    [~,final_symbols] =size(frame_synchronized);
    if i<final_symbols
        frame_synchronized = frame_synchronized(:,1:i);
    end

    


   
end