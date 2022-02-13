function index = symbolSynchronization(data_input)
    load("variables.mat","symbol_length")

    [indexes, pilots] = getContinuousPilots();
    m = zeros(8192,1);
    
    for i = indexes
       m(i+(NFFT-CARRIERS-1)/2,1) = pilots(i+1);
    end        
    pilots = ifft(ifftshift(m));
    
    r =[zeros(8192,1);data_input];
    r_2 = [data_input;zeros(8192,1)];
    b_2 = conj(r).*r_2;
    
    z_3 = zeros(length(r)+length(pilots),1);
    duration = length(b)-length(pilots)-1;
    
    for delay = 0:1:duration
         y  = conj(r(delay+1:delay+length(pilots))).*pilots;
         z_3(delay+1) = sum(y);
    end
    
    % The max values is only searched on the 
    index_finish = symbol_length*1.5;
    z(index_finish+1:end) = 0;
    [~,index] = max(z);


 
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