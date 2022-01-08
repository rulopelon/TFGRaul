function [indexes,values] = getContinuousPilots()
% Function to generate the values of the pilots beans on the OFDM signal,
% according to the DVB-T standard
% The value for each pilot cell is generated randomly according to a PRBS, IN
% this case with the following polynomial
% X11 + X2 + 1 (see figure 1
%
global pilot_cells
global pilot_amplitude
global CARRIERS
indexes = pilot_cells;
values = zeros(1,CARRIERS);
% Sequence to generate the pseudorandom numbers
sequence = ones(1,11);
% All the pilot values for all the beans are calculated
for i = pilot_cells
    % The amplitude value is subtracted to introduce the phase shift in
    % case it is neccesary
    % The ouput form the sequence is obtained
    newbit =sequence(end); 
    values(i+1) = pilot_amplitude -2*pilot_amplitude*newbit;
    % The sequence is updated
    sequence(2:end) = sequence(1:end-1);
    sequence(1) = xor(sequence(end),sequence(end-1));
end

end

