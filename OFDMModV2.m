function [ofdmSymbolsSe,len_symbol]=OFDMModV2(fc,prefix,L)
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY

%% Parameters defined by the standard
Nfft = 8096;
carriers = 6816;
Nsym = 1;
Len_prefix = Nfft*prefix;

% The sample frequency i sgoing to be achieved like in a real environment
% using a 10Mhz, and then interpolating filtering and decimating the signal
Fs_used = 10e6;
L = 64;     % interpolating factor
M = 70;     % decimating factor
Fs_achieved = Fs_used*(L/M); %9.14e6

%%
% The symbols are generated randomly
% Symbols is the vector that will be transformed with the ifft
symbols = exp(1j*pi*randi(64,Nfft,Nsym)/64);   %64 QAM is simulated with 8K mode
% Eliminating carriers not used
symbols(end-(Nfft-carriers)/2 +1:end,:) = 0;
symbols(1:(Nfft-carriers)/2) =0;

% Frequency symbols are transformed to time ofdm symbols
ofdmSymbolsPa = ifft(ifftshift(symbols));
% Cyclic prefix i added, each symbol is added N samples at the beginning,
% from the N las samples 
dim = size(ofdmSymbolsPa);
ofdmSymbolsSended = zeros(dim(1)+Len_prefix,dim(2));

%Symbol prefix is added

ofdmSymbolsSended(:,1) = [ofdmSymbolsPa(end-Len_prefix+1:end,1);ofdmSymbolsPa(:,1)];


len_symbol = Nfft+Len_prefix;


%The signal is multiplied by a carrier to move the frecuency to the desired
t = 0:1/Fs:(Nfft*(Nsym+Len_prefix)-1)/Fs;

%Simulating DAC
% Interpolation of the signal
ofdmSymbolsSe = upsample(ofdmSymbolsSended,L);

% Vector of frecuencies for the dac
f_dac = linspace(-0.5,0.5,Nfft);

%Frecuency response for a non return to zero digital to analog convertion
dac_response = 1/Fs.*sinc(1/Fs*f_dac);

symbols_dac = fftshift(fft(ofdmSymbolsSe,Nfft)).*dac_response;



% The signal is moved to the carrier frequency
imaginary_part = imag(ofdmSymbolsSe).*cos(2*pi*fc*t);
real_part = real(ofdmSymbolsSe).*sin(2*pi*fc*t);
ofdmSymbolsSe = real_part+imaginary_part;



end