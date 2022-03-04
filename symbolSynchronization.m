function indexes = symbolSynchronization(data_input)
    indexes = [];

    load("variables.mat","symbol_length","prefix_length")
    %threshold = 1e-26;
    % Frequency correction is performed before 
    y = [data_input; zeros(NFFT,1)].*conj([zeros(NFFT,1); data_input]);
    % Suma
    z = conv(y.',ones(prefix_length,1));
    threshold = max(z)*0.5;
    indexes_search = find(abs(z)>threshold);
    % Indexes are divided on "steps"
    i = 1;
    %indexes = [indexes,8448];
    index_search = 1;
    while i<= length(indexes_search)
        first_index = indexes_search(i);
        % A line with slope one is created
        estimation = first_index:1:symbol_length+first_index;
        found = false;
        % Searching for the value that starts the step
        j = 0;
        while found == false && j+index_search<= length(indexes_search)
            if indexes_search(j+index_search) > estimation(j+1)+10
                found = true;
                last_index = j+first_index-1;
                index_search = j+index_search;
            end
            j =j+1;
        end
        i = index_search;
        step = z(first_index:last_index);
        [~,index] = max(step);
        indexes = [indexes,index+first_index-1];
       
        if j+index_search>= length(indexes_search)
            step = z(first_index:end);
            [~,index] = max(step);
             indexes = [indexes,index+first_index-1];
            break;
        end
        
        
    end
   
  
    
end