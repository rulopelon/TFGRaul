function [ofdm_exit,len_symbol,Fs_achieved]=OFDMModV2()
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY
% load parameters and constants
global NFFT
global L % Interpolation on the DAC 
global PREFIX %Prefix of the OFDM modulation
global Fc %Frecuency at which the stream of data is modulated
global CARRIERS % Number of non-silent carriers 
global Nsym     % Number of symbols generated each time OFDMModv2 is called
global pilot_cells
global M
global Fs_used
Len_prefix = NFFT*PREFIX;

% The sample frequency is  going to be achieved like in a real environment
% using a 10Mhz, and then interpolating filtering and decimating the signal
Fs_achieved = Fs_used*(L/M); %9.14e6

%%
ofdm_exit = [];
for iteration = 1:1:Nsym
    % The symbols are generated randomly
    % Symbols is the vector that will be transformed with the ifft
    symbols = exp(1j*pi*randi(64,NFFT,1)/64);   %64 QAM is simulated with 8K mode
    % Eliminating CARRIERS not used
    symbols(end-(NFFT-CARRIERS)/2 +1:end,:) = 0;
    symbols(1:(NFFT-CARRIERS)/2) =0;
    pilot_amplitude =4/3;
    for i = pilot_cells
        symbols(i+1+(NFFT-CARRIERS)/2) = pilot_amplitude;
    end

    % Frequency symbols are transformed to time ofdm symbols
    ofdmSymbolsPa = ifft(ifftshift(symbols));
    % Cyclic prefix i added, each symbol is added N samples at the beginning,
    % from the N las samples 
    dim = size(ofdmSymbolsPa);
    ofdmSymbolsSended = zeros(dim(1)+Len_prefix,dim(2));

    %Symbol prefix is added
    ofdmSymbolsSended(:,1) = [ofdmSymbolsPa(end-Len_prefix+1:end,1);ofdmSymbolsPa(:,1)];

    %The signal is multiplied by a carrier to move the frecuency to the desired
    t = 0:1/Fs_achieved:((NFFT+Len_prefix)*L/M)/Fs_achieved;
    t = t(1:end-1);
    %Simulating DAC

    % Vector of frecuencies for the dac at 10Mhz
    f_dac = linspace(-0.5,0.5,(NFFT+Len_prefix)*L/M);
    % Interpolation of the signal
    ofdmSymbolsSe = interpolacion(ofdmSymbolsSended,L);
    % The signal is filtered
    interpolation_filter = getFilter(M,L,(NFFT+Len_prefix)*L,false);


    % To eliminate not wanted frequencies caused by the interpolation
    %ofdmSymbolsSe_processed = filter(interpolation_filter,1,ofdmSymbolsSe);

    ofdmSymbolsSe_processed = fftshift(fft(ofdmSymbolsSe,(NFFT+Len_prefix)*L)).* interpolation_filter';
    ofdmSymbolsSe = ifft(ifftshift(ofdmSymbolsSe_processed));
    %Decimation
    ofdmSymbolsSe = ofdmSymbolsSe_processed(1:M:length(ofdmSymbolsSe));



    %Frecuency response for a non return to zero digital to analog convertion
    dac_response = 1/Fs_achieved.*sinc((1/Fs_achieved)*f_dac);

    symbols_dac = fftshift(fft(ofdmSymbolsSe,(NFFT+Len_prefix)*L/M)).*dac_response';

    %Symbols at the exit
    symbols_dac = ifft(ifftshift(symbols_dac));


    % The signal is moved to the carrier frequency
    imaginary_part = imag(symbols_dac).*cos(2*pi*Fc*t');
    real_part = real(symbols_dac).*sin(2*pi*Fc*t');
    ofdm_modulated = real_part+imaginary_part;

    ofdm_exit = [ofdm_exit,ofdm_modulated];
end

len_symbol = NFFT+Len_prefix;
ofdm_exit = reshape(ofdm_exit,[],1);


end