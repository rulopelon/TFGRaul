%% Code to test if the getContinuousPilots function works properly
% The environment is reseted
clc, clear;
parameters;
f_vector = zeros(NFFT,1);
correct_f_vector = zeros(NFFT,1);

% Pilots with the getContinuousPilots function are generated
[indexes, pilot_values]=getContinuousPilots();
for i = indexes
    f_vector(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
end
correct_pilots = correctPilots(CARRIERS);

for i = indexes
    correct_f_vector(i+(NFFT-CARRIERS-1)/2,1) = correct_pilots(i+1);
end

% Pilots are ploted
disp(isequal(pilot_values,correct_pilots))
figure
subplot(4,1,1)
plot(abs(pilot_values))
title("Pilots getContinuousPilots() generated")

subplot(4,1,2)
plot(abs(correct_pilots))
title("Correct pilots")

subplot(4,1,3)
plot(abs(f_vector))
title("Final OFDM signal")

subplot(4,1,4)
plot(abs(correct_f_vector))
title("Correct OFDM signal")
