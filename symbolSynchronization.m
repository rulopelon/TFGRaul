function indexes = symbolSynchronization(data_input)
    load("variables.mat","prefix_length","NFFT","CARRIERS")
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
    z = abs(conv(y.',ones(prefix_length,1)));
    
    y_2 = abs([data_input; zeros(NFFT,1)]).^2+ abs([zeros(NFFT,1); data_input]).^2;
    % Second function
    z_2 = conv(y_2.',ones(prefix_length,1));
    %Alfa_cp
    alpha_cp =z+(ro/2)*z_2;
    
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
    
    [~,time_index] = max(estimator);

    %% Frequency synchronization















%     threshold = max(z)*0.5;
%     indexes_search = find(abs(z)>threshold);
%     % Indexes are divided on "steps"
%     i = 1;
%     %indexes = [indexes,8448];
%     index_search = 1;
%     while i<= length(indexes_search)
%         first_index = indexes_search(i);
%         % A line with slope one is created
%         estimation = first_index:1:symbol_length+first_index;
%         found = false;
%         % Searching for the value that starts the step
%         j = 0;
%         while found == false && j+index_search<= length(indexes_search)
%             if indexes_search(j+index_search) > estimation(j+1)+10
%                 found = true;
%                 last_index = j+first_index-1;
%                 index_search = j+index_search;
%             end
%             j =j+1;
%         end
%         i = index_search;
%         step = z(first_index:last_index);
%         [~,index] = max(step);
%         indexes = [indexes,index+first_index-1];
%        
%         if j+index_search>= length(indexes_search)
%             step = z(first_index:end);
%             [~,index] = max(step);
%              indexes = [indexes,index+first_index-1];
%             break;
%         end
%         
%         
%     end
   
  
    
end