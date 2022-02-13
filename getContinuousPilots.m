function [indexes,values] = getContinuousPilots()
% Function to generate the values of the pilots beans on the OFDM signal,
% according to the DVB-T standard
% The value for each pilot cell is generated randomly according to a PRBS, IN
% this case with the following polynomial
% X11 + X2 + 1 (see figure 1
%
load("variables.mat","CARRIERS","pilot_cells")

indexes = pilot_cells;
%To storage the values obtained in the sequence
values = zeros(1,CARRIERS);

% Sequence to generate the pseudorandom numbers
sequence = ones(1,11);

for i = 1:1:CARRIERS
    values(i) = sequence(end);
    sequence = [xor(sequence(end),sequence(end-2)),sequence(1:end-1)];
end
for i =1:1:length(values)
    values(i) = 4/3*2*(1/2-values(i));
end

end

