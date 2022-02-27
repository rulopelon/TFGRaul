function indexes = symbolSynchronization(data_input)
    indexes = [];

    load("variables.mat","symbol_length","threshold")
    threshold = 1e-26;
    % Frequency correction is performed before 
    y = [data_input; zeros(8192,1)].*conj([zeros(8192,1); data_input]);
    % Suma
    z = conv(y.',ones(256,1));
    % The max values is only searched on the
    indexes_search = find(abs(z)>threshold);
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