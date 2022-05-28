function [values] = getReferenceSequence()
% getReferenceSequence Function to get the reference sequence base on the
% dvb-t standard
    load("variables.mat","CARRIERS")

    %To storage the values obtained in the sequence
    values = zeros(1,CARRIERS);
    
    % Sequence to generate the pseudorandom numbers
    sequence = ones(1,11);
    for i = 1:1:CARRIERS
        values(i) = sequence(end);
        sequence = [xor(sequence(end),sequence(end-2)),sequence(1:end-1)];
    end
end

