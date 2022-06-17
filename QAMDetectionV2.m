function [symbol_estimated] = QAMDetectionV2(data,scattered_pilots_vector)
    load("variables.mat","nAM","NFFT","CARRIERS")
   
    %The minimum distance algorithm is going to be used
    % Based on the type of Qam modulation, the branches for the detection
    % are created
    % The algorithm must ifnore the values at the continual piltos
    % positions and the scattered pilots positions
    

    values = 0:1:sqrt(nAM)-1;
    values = values-(sqrt(nAM)-1)/2;
    %values = values*2;
    %values = values./sqrt(42);
     
    % Getting the pilot indexes
    [indexes, ~]=getContinuousPilots();
    indexes= indexes+(NFFT-CARRIERS-1)/2;

    for index = 1:1:length(data)
        % Check that it is not a pilot (continual or scattered)
        if ismember(index,indexes)==0 && index>=(NFFT-CARRIERS-1)/2 &&index<(NFFT-CARRIERS)/2+CARRIERS && ismember(index,scattered_pilots_vector)==0
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

