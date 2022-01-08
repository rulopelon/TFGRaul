function [ofdm_exit,len_symbol,Fs_achieved]=OFDMModV2()
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY
% load parameters and constants
global NFFT
global L % Interpolation on the DAC 
global PREFIX %Prefix of the OFDM modulation
global CARRIERS % Number of non-silent carriers 
global Nsym     % Number of symbols generated each time OFDMModv2 is called
global M
global Fs_used
global nAM

Len_prefix = NFFT*PREFIX;

% The sample frequency is  going to be achieved like in a real environment
% using a 10Mhz, and then interpolating filtering and decimating the signal
Fs_achieved = Fs_used*(M/L); %9.14e6

%%
ofdm_exit = [];
for iteration = 1:1:Nsym
    % The symbols are generated randomly
    % Symbols is the vector that will be transformed with the ifft
    %Real part
    real_symbols = randi(sqrt(nAM)*2,NFFT)-sqrt(nAM)-1/2;
    real_symbols = real_symbols(:,1);
    %Imaginary part
    imag_symbols = randi(sqrt(nAM)*2,NFFT)-sqrt(nAM)-1/2;
    imag_symbols = 1i*imag_symbols(:,1);
    
    symbols = real_symbols+imag_symbols;
    % Normalizing the symbols
    symbols = symbols/max(abs(symbols));
    
    % Eliminating CARRIERS not used
    symbols(end-(NFFT-CARRIERS)/2 +1:end,:) = 0;
    symbols(1:(NFFT-CARRIERS)/2) =0;
    
    %Continuous pilots are added to the OFDM signal
    [indexes, pilot_values]=getContinuousPilots();
    for i = indexes
        symbols(i+(NFFT-CARRIERS)/2,1) = pilot_values(i+1);
    end

    % Frequency symbols are transformed to time ofdm symbols
    ofdmSymbolsPa = ifft(ifftshift(symbols));
    % Cyclic prefix i added, each symbol is added N samples at the beginning,
    % from the N last samples 
    dim = size(ofdmSymbolsPa);
    ofdmSymbolsSended = zeros(dim(1)+Len_prefix,dim(2));

    %Symbol prefix is added
    ofdmSymbolsSended(:,1) = [ofdmSymbolsPa(end-Len_prefix+1:end,1);ofdmSymbolsPa(:,1)];

      %Simulating DAC
    
    % The base Fs for the signal is 9.14e6 Hz, so we need to acomplish 10
    % Mhz as decimal frequencies cannot be achieved
    % Vector of frecuencies for the dac at 10Mhz
    % Interpolation of the signal
    ofdmSymbolsSe = interpolation(ofdmSymbolsSended,M);
    % The signal is filtered
    interpolation_filter = getFilter(L,M);
    % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
    ofdmSymbolsSe_processed = conv(ofdmSymbolsSe,interpolation_filter,'same');
   
    %Decimation
    ofdmSymbolsSe = ofdmSymbolsSe_processed(1:L:length(ofdmSymbolsSe_processed));
    
    %Vector of frecuencies
    f_dac = -0.5:1/Fs_achieved:0.5;
    %Frecuency response for a non return to zero digital to analog convertion
    dac_response = 1/Fs_achieved.*sinc((1/Fs_achieved)*f_dac);
    
    symbols_dac = conv(ofdmSymbolsSe,ifft(ifftshift(dac_response)),'same');

    ofdm_exit = [ofdm_exit,symbols_dac];
end

len_symbol = NFFT+Len_prefix;
ofdm_exit = reshape(ofdm_exit,[],1);


end