function signal_upsampled = interpolacion(signal,L)
    signal_upsampled = [];
    if L >1
        for i  =1:1:length(signal)
            b = [signal(i),zeros(1,L-1)];
            signal_upsampled = [signal_upsampled,b];
        end
         signal_upsampled = signal_upsampled';
    elseif L==1
          signal_upsampled = signal;
    
    end
    
end

