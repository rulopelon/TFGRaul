function [symbol_estimated] = QAMDetection(data)
    load("variables.mat","nAM","NFFT","CARRIERS")
   
    %The minimum distance algorithm is going to be used
    % Based on the type of Qam modulation, the branches for the detection
    % are created
    values = 0:1:sqrt(nAM)-1;
    values = values-(sqrt(nAM)-1)/2;
    % Getting the pilot indexes
    [indexes, ~]=getContinuousPilots();
    i = 0;
    indexes= indexes+(NFFT-CARRIERS-1)/2;
    for index = 1:1:length(data)
        % Check that it is not a pilot
        if ismember(index,indexes)==0 && index>=(NFFT-CARRIERS-1)/2 &&index<(NFFT-CARRIERS)/2+CARRIERS+1
            i = i+1;
            % Real and complex parts are compared
            value = data(index);
            real_part = real(data(index));
            imag_part = imag(data(index));
            % The difference with the values is performed on both
            % dimensions
            real_difference = values-real_part;
            imag_difference = values-imag_part;
            %The minimum is calculated
            [~,real_index] = min(abs(real_difference));
            [~,imag_index] = min(abs(imag_difference));
            %Getting the values
            real_part_calculated= values(real_index);
            imag_part_calculated = values(imag_index);
            data(index) = real_part_calculated+imag_part_calculated*1i;
            
        end

    end
    symbol_estimated = data;
end

