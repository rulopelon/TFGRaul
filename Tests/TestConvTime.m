%% Script to test the velocity of a convolution against performing the fft and 
% multiplication
clc, close all, clear

iterations = 1000;
conv_results = zeros(iterations,1);
fft_results = zeros(iterations,1);

for i =1:1:iterations
    % Generating random numbers
    random_vector  = rand(100000,1);
    % Convolution
    tic
    a= conv(random_vector,random_vector);
    time_elapsed = toc;
    conv_results(i) =time_elapsed;
    % Convolution
    tic
    a= fft(random_vector).*fft(random_vector);
    time_elapsed = toc;
    fft_results(i) =time_elapsed;

end
figure
subplot(2,1,1)
plot(conv_results)
title("Resultados convolución")
subplot(2,1,2)
plot(fft_results)
title("Resultados transformada Fourier")