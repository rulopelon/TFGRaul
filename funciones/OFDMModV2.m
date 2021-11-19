function [ofdm_exit,len_symbol,Fs_achieved]=OFDMModV2(fc,prefix)
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY

%% Parameters defined by the standard
Nfft = 8096;
carriers = 6816;
Nsym = 1;
Len_prefix = Nfft*prefix;
pilot_cells = [0 48 54 87 141 156 192 201 255 279 282 333 432 450 ...
483 525 531 618 636 714 759 765 780 804 873 888 ...
918 939 942 969 984 1050 1101 1107 1110 1137 1140 ...
1146 1206 1269 1323 1377 1491 1683 1704 1752 ...
1758 1791 1845 1860 1896 1905 1959 1983 1986 ...
2037 2136 2154 2187 2229 2235 2322 2340 2418 ...
2463 2469 2484 2508 2577 2592 2622 2643 2646 ...
2673 2688 2754 2805 2811 2814 2841 2844 2850 ...
2910 2973 3027 3081 3195 3387 3408 3456 3462 ...
3495 3549 3564 3600 3609 3663 3687 3690 3741 ...
3840 3858 3891 3933 3939 4026 4044 4122 4167 ...
4173 4188 4212 4281 4296 4326 4347 4350 4377 ...
4392 4458 4509 4515 4518 4545 4548 4554 4614 ...
4677 4731 4785 4899 5091 5112 5160 5166 5199 ...
5253 5268 5304 5313 5367 5391 5394 5445 5544 ...
5562 5595 5637 5643 5730 5748 5826 5871 5877 ...
5892 5916 5985 6000 6030 6051 6054 6081 6096 ...
6162 6213 6219 6222 6249 6252 6258 6318 6381 ...
6435 6489 6603 6795 6816];    

% The sample frequency is  going to be achieved like in a real environment
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
pilot_amplitude =4/3;
for i = pilot_cells
    symbols(i+1+(Nfft-carriers)/2) = pilot_amplitude;
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
t = 0:1/Fs_achieved:((Nfft+Len_prefix)*L/M)/Fs_achieved;
t = t(1:end-1);
%Simulating DAC

% Vector of frecuencies for the dac at 10Mhz
f_dac = linspace(-0.5,0.5,(Nfft+Len_prefix)*L/M);
% Interpolation of the signal
ofdmSymbolsSe = interpolacion(ofdmSymbolsSended,L);
% The signal is filtered
interpolation_filter = getFilter(M,L,(Nfft+Len_prefix)*L,false);


% To eliminate not wanted frequencies caused by the interpolation
%ofdmSymbolsSe_processed = filter(interpolation_filter,1,ofdmSymbolsSe);

ofdmSymbolsSe_processed = fftshift(fft(ofdmSymbolsSe,(Nfft+Len_prefix)*L)).* interpolation_filter';
ofdmSymbolsSe = ifft(ifftshift(ofdmSymbolsSe_processed));
%Decimation
ofdmSymbolsSe = ofdmSymbolsSe_processed(1:M:length(ofdmSymbolsSe));



%Frecuency response for a non return to zero digital to analog convertion
dac_response = 1/Fs_achieved.*sinc((1/Fs_achieved)*f_dac);

symbols_dac = fftshift(fft(ofdmSymbolsSe,(Nfft+Len_prefix)*L/M)).*dac_response';

%Symbols at the exit
symbols_dac = ifft(ifftshift(symbols_dac));


% The signal is moved to the carrier frequency
imaginary_part = imag(symbols_dac).*cos(2*pi*fc*t');
real_part = real(symbols_dac).*sin(2*pi*fc*t');
ofdm_exit = real_part+imaginary_part;

len_symbol = Nfft+Len_prefix;



end