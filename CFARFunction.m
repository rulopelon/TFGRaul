function processed_matrix= CFARFunction(caf_matrix)
%CFARFUNCTION Function to perform 2d CFAR analysis of the recieved CAF
%matrix
load("variables.mat","Range_training_cells","Doppler_training_cells","Range_guard_cells","Doppler_guard_cells")

[range_size,doppler_size] = size(caf_matrix);
offset = 1.4;
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=doppler_size;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=range_size;                  %for length of time OR # of range cells



processed_matrix = zeros(range_size,doppler_size);

for i = Range_training_cells+Range_guard_cells+1 : Nr/2-(Range_guard_cells+Range_training_cells) % over range
    for j = Doppler_training_cells+Doppler_guard_cells+1 : Nd-(Doppler_guard_cells+Doppler_training_cells) % over doppler
        noise_level = zeros(1,1);
        for p = i-(Range_training_cells+Range_guard_cells): i+ (Range_training_cells+Range_guard_cells)
            for q = j-(Doppler_training_cells+Doppler_guard_cells): j+(Doppler_training_cells+Doppler_guard_cells)
                if (abs(i-p)> Range_guard_cells ||abs(j-q)>Doppler_guard_cells)
                    % convert value from log to linear using db2pow
                    noise_level = noise_level+ db2pow(caf_matrix(p,q));
                end
            end

        end
        %after averaging, convert it back to logarithmic using pow2db
        threshold = pow2db(noise_level/(2*(Doppler_training_cells+Doppler_guard_cells+1)*2*(Range_training_cells+Range_guard_cells+1)-(Range_guard_cells*Doppler_guard_cells)-1));
        % add offset to the noise determine the threshold.
        threshold = threshold + offset;
        
        % compare the signal under CUT against this threshold
        % If the CUT level > threshold assign 1, else equate to 0
        CUT= caf_matrix(i,j);
        if (CUT<threshold)
            processed_matrix(i,j)=0;
        else 
            processed_matrix(i,j)= 1; % max_T
            disp(i);
            disp(j);
        end
        %if (caf_matrix(i+d_margin/2, j+r_margin/2) > sig_threshold)
        %    sig_CFAR(i+d_margin/2, j+r_margin/2) = 1;
        %else sig_CFAR(i+d_margin/2, j+r_margin/2) = 0;
        %end

        
    end
end
end

