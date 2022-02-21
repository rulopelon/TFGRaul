function index = symbolSynchronization(data_input)

    load("variables.mat","symbol_length")
    % Frequency correction is performed before 
    y = [data_input; zeros(8192,1)].*conj([zeros(8192,1); data_input]);
    % Suma
    z = conv(y.',ones(256,1));
    % The max values is only searched on the 
    index_finish = symbol_length*1.5;
    z(index_finish+1:end) = 0;
    [~,index] = max(z);
    disp(index);
    
     
    %     global symbol_length
    %     b = data_input.';
    %     y = [b; zeros(8192,1)].*conj([zeros(8192,1); b]);
    %     % Sum
    %     z = conv(y.',ones(256,1));
    %     % The max values is only searched on the 
    %     index_finish = symbol_length*1.5;
    %     z(index_finish+1:end) = 0;
    %     [~,index] = max(z);
end