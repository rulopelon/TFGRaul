%% Reciever for the Adalm Pluto SDR
load('plutoVariables.mat')

% The reciever object is created
rxPluto = sdrrx('Pluto','CenterFrequency',centerFrequency,'BasebandSampleRate',baseBandFrequency,'SamplesPerFrame',samplesIteration);

while true
    % Data is obtained from the SDR
    data = rxPluto();
    % Data is sended to the recuiever
    plot(abs(fftshift(fft(data))))
    reciever(data)
end
