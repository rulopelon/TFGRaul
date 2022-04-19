function [frame_synchronized,base_line]  = symbolSynchronization(data_input)
    load("variables.mat","prefix_length","NFFT","CARRIERS","symbol_length")
    %% Time synchronization
    indexes = [];
    [indexes_pilots, pilots] = getContinuousPilots();
    m = zeros(8192,1);
    for i = indexes_pilots
       m(i+(NFFT-CARRIERS-1)/2,1) = pilots(i+1);
    end        
    pilots = ifft(ifftshift(m));

    ro =0.5; %CHANGE

    %Calculating alfa cp
    y = [data_input; zeros(NFFT,1)].*conj([zeros(NFFT,1); data_input]);
    % Add
    z = conv(y.',ones(prefix_length,1));
    
    y_2 = abs([data_input; zeros(NFFT,1)]).^2+ abs([zeros(NFFT,1); data_input]).^2;
    % Second function
    z_2 = conv(y_2.',ones(prefix_length,1));
    %Alfa_cp
    alpha_cp =abs(z)+(ro/2)*z_2;
    
    %Calculating alpha ro
    %Third function
    z_3 = abs(conv(conj(data_input),flip(pilots)));
    %Fourth function
    r =[zeros(NFFT,1);data_input];
    r_2 = [data_input;zeros(NFFT,1)];
    b_2 = conj(r+r_2);
    pilots = flip(pilots);
    z_4 = abs(conv(b_2,pilots));

    %Alpha ro
    alpha_ro = (1+ro).*z_3-ro.*z_4(1:length(z_3));
    
    % Calculating the estimator
    estimator = ro.*alpha_cp(1:length(z_3))+(1-ro).*alpha_ro.';
    %Deleting unwanted peaks
    estimator(1:symbol_length-1) = 0;
   

    threshold = max(estimator)*0.5;
    %DELETE
    reference = 1:1:length(estimator);
    reference(:)= threshold;

    indexes_search = find(abs(estimator)>threshold);
    % Indexes are divided on "steps"
    i = 1;
    index_search = 1;
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
        indexes = [indexes,index+first_index-1];
       
        if j+index_search>= length(indexes_search)
            step = estimator(first_index:end);
            [~,index] = max(step);
             indexes = [indexes,index+first_index-1];
            break;
        end
    end

    
    %% Frequency synchronization
    frequency_estimator =-(1/(2*pi)).*angle(z);
    %% Symbol splitting
    initial_index = indexes(1);
    disp(initial_index)
    N_symbols = ceil(length(data_input)/symbol_length);
    
    artificial_indexes = zeros(1,N_symbols);
    for i =0:1:N_symbols-1
        artificial_indexes(i+1) =(NFFT+prefix_length)*i+initial_index;
        
    end
    % Number of symbols recieved
    
    frame_synchronized = zeros(NFFT+prefix_length,N_symbols);
    
    i = 1;
    for index= artificial_indexes
        if index-NFFT-prefix_length+1<=length(data_input)-NFFT-prefix_length && index-NFFT-prefix_length >0
            frame = data_input(index-NFFT-prefix_length+1:index,1);
            %Frequency deviation estimation
            frequency_deviation = frequency_estimator(index)/length(frame);
            %frequency_deviation = 0;
            %Frequency deviation correction
            n =0:1:length(frame)-1;
            frame = frame.*exp(-1i*2*pi*frequency_deviation*n.');
            frame_synchronized(:,i) = frame;
            i = i+1;
        end
    end
    
    [~,final_symbols] =size(frame_synchronized);
    if i<final_symbols
        frame_synchronized = frame_synchronized(:,1:i);
    end
    % Deleting the prefix
    frame_synchronized = frame_synchronized(prefix_length+1:end,:);
    
    %Calculating the base line distance
    base_line = initial_index-symbol_length;

   
end