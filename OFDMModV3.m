function [ofdm_exit,ofdm_exit_2]=OFDMModV3(Nsym)
% MODIFIED BY RAUL GONZALEZ in order to adapt the code to the DVB-T
% standard
% incluying scattered pilots
% load parameters and constants
load("variables.mat","NFFT","L","PREFIX","CARRIERS","M","nAM","reconstruction_filter","symbol_length_emitter","number_scatter_pilots")

Len_prefix = NFFT*PREFIX;

% The sample frequency is  going to be achieved like in a real environment
% using a 10Mhz, and then interpolating filtering and decimating the signal

%%
alocation = zeros(symbol_length_emitter,Nsym);
ofdm_exit_2 = [];

%Continuous pilots are added to the OFDM signal
[indexes, pilot_values]=getContinuousPilots();


% Scattered pilots vector
scattered_pilots_vector =(0 + 3*rem(1,4) + 12*(0:CARRIERS));
% Getting the reference sequence
reference_sequence = getReferenceSequence();

j = 0;
for iteration = 1:1:Nsym
    % The symbols are generated randomly
    % Symbols is the vector that will be transformed with the ifft   
    symbols = (randi(sqrt(nAM),NFFT,1)-1-(sqrt(nAM)-1)/2)+1i*(randi(sqrt(nAM),NFFT,1)-1-(sqrt(nAM)-1)/2);
    %symbols = zeros(NFFT,1);
    % Deleting CARRIERS not used
    symbols(end-(NFFT-CARRIERS-1)/2 +1:end,:) = 0;
    symbols(1:(NFFT-CARRIERS-1)/2) =0;

    % Variable for the scattered pilots
    pilot  = 1;
    
    %Introducing continuous pilots
    for i = indexes
        symbols(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
    end
    % Introducing the scattered pilots
    for i= 1:CARRIERS
        if i == scattered_pilots_vector(pilot) && i+3*j<CARRIERS
            symbols(i+3*j+(NFFT-CARRIERS-1)/2) = 4/3*2*(1/2-reference_sequence(i));
            %symbols(i+3*j) = 4/3*2*(1/2-reference_sequence(i));
            pilot = pilot+1;
        end
    end

    % Frequency symbols are transformed to time ofdm symbols
    ofdmSymbolsPa = ifft(ifftshift(symbols));
    % Cyclic prefix i added, each symbol is added N samples at the beginning,
    % from the N last samples 

    %Symbol prefix is added
    ofdmSymbolsSended= [ofdmSymbolsPa(end-Len_prefix+1:end,1);ofdmSymbolsPa];

    %Simulating DAC
    
    % The base Fs for the signal is 9.14e6 Hz, so we need to acomplish 10
    % Mhz as decimal frequencies cannot be achieved
    % Vector of frecuencies for the dac at 10Mhz
    % Interpolation of the signal
    ofdmSymbolsSe = interpolation(ofdmSymbolsSended,M);
    % The signal is filtered
    
    % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
    ofdmSymbolsSe_processed = conv(ofdmSymbolsSe,reconstruction_filter,'same');
   
    %Decimation
    ofdmSymbolsSe = ofdmSymbolsSe_processed(1:L:length(ofdmSymbolsSe_processed));
    
    alocation(:,iteration) = ofdmSymbolsSe;
    ofdm_exit_2= [ofdm_exit_2,ofdmSymbolsSended.'];
    % Check if the pilot has exceeded the maximum value
    
    if j==3
        j = 0;
    else
        j = j+1;
    end
end
ofdm_exit = alocation(:);




end