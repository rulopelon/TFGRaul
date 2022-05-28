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
    disp(initial_index)
    N_symbols = ceil(length(data_input)/symbol_length);
    
%     artificial_indexes = zeros(1,N_symbols);
%     for i =0:1:N_symbols-1
%         artificial_indexes(i+1) =(NFFT+prefix_length)*i+initial_index;
%         
%     end
    %Reference signal for equalization
    frequency_reference = zeros(NFFT,1);
    [indexes_equalization, pilot_values]=getContinuousPilots();
    
    for i = indexes_equalization
        frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
    end

    % Number of symbols recieved
    frame_synchronized = zeros(NFFT+prefix_length,N_symbols);
    
    i = 1;
    % Modes for the scatter pilots
    modes = zeros(N_symbols,1);
    j = 1;
    %Iterating all the symbols
    for index_synchronization= indexes_synchronization
        if index_synchronization-NFFT-prefix_length+1<=length(data_input)-NFFT-prefix_length && index_synchronization-NFFT-prefix_length >0
            frame = data_input(index_synchronization-NFFT-prefix_length+1:index_synchronization,1);
            frame = fftshift(fft(frame));
            %Frequency deviation estimation
            frequency_deviation = frequency_estimator(index_synchronization)/length(frame);

            %Frequency deviation correction
            n =0:1:length(frame)-1;
            %frame = frame.*exp(-1i*2*pi*frequency_deviation*n.');

            % Performing scattered pilot detection as in timing
            % synchronization for DVB-T Systems
            k_values = [0,1,2,3];
            correlations  = zeros(length(k_values),1);
            i_values_vector = 1:1:(NFFT/12)-1;
            for k= k_values
                indexed_positions  = 3*k+i_values_vector+(NFFT-CARRIERS-1)/2;
                correlations(k+1) = sum(frame(indexed_positions).*conj(frame(indexed_positions)));
            end
            [value,mode] = max(correlations);
            
            % Saving the mode
            modes(i) = j;
            
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
            scattered_pilots_vector = scattered_pilots_vector(1:find(scattered_pilots_vector>CARRIERS));

            % On the synchronization techniques for wireless OFDM systems
            shift = angle(sum(frame(scattered_pilots_vector).*conj(frame(scattered_pilots_vector))));
            % Calculating the index
            fine_index = round(index_synchronization+shift);
            frame = data_input(fine_index-NFFT-prefix_length+1:fine_index,1);
            
            %Frequency deviation estimation
            frequency_deviation = frequency_estimator(fine_index)/length(frame);
            %Frequency deviation correction
            n =0:1:length(frame)-1;
            frame = frame.*exp(-1i*2*pi*frequency_deviation*n.');

            % Adding the synchronized frame to the output
            frame_synchronized(:,i) = frame;
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
    % Deleting the prefix
    frame_synchronized = frame_synchronized(prefix_length+1:end,:);
    


   
end