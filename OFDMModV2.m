function [ofdm_exit]=OFDMModV2(Nsym)
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY
% load parameters and constants
global NFFT
global L % Interpolation on the DAC 
global PREFIX %Prefix of the OFDM modulation
global CARRIERS % Number of non-silent carriers 
global M
global Fs_used
global nAM
global reconstruction_filter

Len_prefix = NFFT*PREFIX;

% The sample frequency is  going to be achieved like in a real environment
% using a 10Mhz, and then interpolating filtering and decimating the signal
Fs_achieved = Fs_used*(M/L); %9.14e6

%%
ofdm_exit = [];

%Continuous pilots are added to the OFDM signal
[indexes, pilot_values]=getContinuousPilots();

for iteration = 1:1:Nsym
    % The symbols are generated randomly
    % Symbols is the vector that will be transformed with the ifft   
    symbols = (randi(sqrt(nAM),NFFT,1)-1-(sqrt(nAM)-1)/2)+1i*(randi(sqrt(nAM),NFFT,1)-1-(sqrt(nAM)-1)/2);

       % Normalizing the symbols
    symbols = symbols/max(abs(symbols));
    
    % Eliminating CARRIERS not used
    symbols(end-(NFFT-CARRIERS-1)/2 +1:end,:) = 0;
    symbols(1:(NFFT-CARRIERS-1)/2) =0;
    
    
    for i = indexes
        symbols(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
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
    


    ofdm_exit = [ofdm_exit,ofdmSymbolsSe'];
end




end