function  RecieverNoResampling(data)
% Reciever with channel equalization
load("variables.mat", ...
    "PREFIX","CARRIERS","NFFT","Fs_used","PROPAGATION_VELOCITY")


prefix_length = PREFIX*NFFT;
% Coarse frequency synchronization

%Frame synchronism
number_symbols = floor(length(data)/NFFT);
data = data(1:number_symbols*NFFT);

% Getting the indexes with the start of each symbol
frame_synchronized = reshape(data,NFFT,[]);

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

for i = indexes
    frequency_reference(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end

for i = 1:1:symbols
    symbol_equalize = frame_synchronized(:,i);
    symbol_equalize_fft = fftshift(fft(symbol_equalize));
    channel_estimation = nan(NFFT,1);
    for index = indexes
        index_evaluate = index+((NFFT-CARRIERS-1)/2);
        channel_estimation(index_evaluate) =symbol_equalize_fft(index_evaluate)/frequency_reference(index_evaluate);
    end
    %Query points for the interpolation

    channel_estimation_interpolated = fillmissing(channel_estimation,'nearest');
    channel_estimation_interpolated(end+1-(NFFT-CARRIERS-1)/2:end) = 0;
    channel_estimation_interpolated(1:(NFFT-CARRIERS-1)/2-1) =0;
    % Calculating the correction
    frequency_correction = 1./channel_estimation_interpolated;
    %Substituting inf values with zeros
    inf_indexes = find(isinf(frequency_correction));
    for index= inf_indexes
        frequency_correction(index)=0;
    end
 
    % The symbol is equalized
    symbol_frequency_corrected = symbol_equalize_fft.*frequency_correction;
    
    
    %Processing to get two signals
    symbol_QAM_corrected =QAMDetection(symbol_frequency_corrected); 
    %Deleting clutter
    signal_substracted = symbol_equalize_fft -channel_estimation_interpolated(:,1).*symbol_QAM_corrected(:,1);

    
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
%Deleting random peaks at delay 0
%caf_matrix(1:4,:) = 0;
%Calculating the maximum
[doppler_columns,time_indexes] = max(caf_matrix);
[~,doppler_index]= max(doppler_columns);
    
bistatic_range = time_indexes(doppler_index);
disp(bistatic_range)
doppler_frequency = doppler_axis(doppler_index);


base_line = 3698;
%Showing the ellipse of the posible positions of the plane
%Calculating the distance of each step
step_distance = (1/Fs_used)*PROPAGATION_VELOCITY;
bistatic_range  = bistatic_range*step_distance;

if base_line < bistatic_range
    %Calculating ellipse parameters
    a = bistatic_range/2;
    b = sqrt((bistatic_range/2)^2-(base_line/2)^2);
    x1  =0;
    y1 = 0;
    x2 = x1+base_line;
    y2 = 0;
    
    t = linspace(0,2*pi);
    X = a*cos(t);
    Y = b*sin(t);
    w = atan2(y2-y1,x2-x1);
    x = (x1+x2)/2 + X*cos(w) - Y*sin(w);
    y = (y1+y2)/2 + X*sin(w) + Y*cos(w);
    
    %Plotting the results
    figure
    plot(x,y)
    hold on
    plot(x1,y1,'o')
    plot(x2,y2,'o')
    axis equal
    title("2D Biestatic estimation")
    
    %Plotting on 3d
    [x,y,z] = ellipsoid(base_line/2,0,0,a,b,a);
    z(1:int64(floor(length(z)))/2,:) = 0;
    figure
    surf(x,y,z,'FaceAlpha',0.5)
    hold on
    plot3(x1,y1,0,'ko','MarkerSize',3,'MarkerFaceColor','yellow','MarkerEdgeColor','yellow')
    plot3(x2,y2,0,'ko','MarkerSize',3,'MarkerFaceColor','yellow','MarkerEdgeColor','yellow')
    title("3D Biestatic estimation")
else
    disp("There is an error on the estimation")
     input("Waiting your input")
end


end


