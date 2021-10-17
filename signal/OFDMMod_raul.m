function [ofdmSymbolsSe,len_symbol]=OFDMMod(modSymbols,fc,Fs,NFFT,k,prefix,L)
% MODIFIED BY RAUL GONZALEZ TO CHANGE THE FRECUENCY
%Number of FFT needed


h = comm.PSKModulator('ModulationOrder',4,'SymbolMapping','gray','BitInput',true,'PhaseOffset',0);
modSymbols = h(modSymbols);
modSymbols = modSymbols(:).'; % arrange in row

Nf = length(k);
if mod(length(modSymbols),Nf)~=0
    error('modSymbols'' length must be an integer number of tines Nf') ;
end

Nsym = length(modSymbols)/Nf;
modSymbolsBlock = reshape(modSymbols,length(modSymbols)/Nsym,Nsym);

% An array with as many rows as the size of FFT and as many cols as 
% the number of symbols which can be introduced on each OFDM symbol 
ofdmSymbolsFreq = zeros(NFFT,Nsym);
for j =1:1:Nsym
    a = 1;
    for l =k
        ofdmSymbolsFreq(l,j) = modSymbolsBlock(a,j);
        % The conjugated and fliped
        ofdmSymbolsFreq(NFFT-l) = conj(modSymbolsBlock(a,j));
        a = a+1;
    end
end

%ofdmSymbolsFreq =[zeros(Nsym,((NFFT/2)-Nf)/2) conj(fliplr(modSymbolsBlock))  zeros(Nsym,((NFFT/2)-Nf)/2)  zeros(Nsym,(((NFFT/2)-Nf)/2)+1)  modSymbolsBlock zeros(Nsym,(((NFFT/2)-Nf)/2)-1)];

ofdmSymbolsPa = (NFFT/sqrt((Nf)*2))*ifft(ofdmSymbolsFreq.');
% Cyclic prefix i added, each symbol is added N samples at the beginning,
% from the N las samples 
dim = size(ofdmSymbolsPa);
ofdmSymbolsSended = zeros(dim(1),dim(2)+prefix);

%Symbol prefix is added
for i = 1:1:dim(1)
    ofdmSymbolsSended(i,:) = [ofdmSymbolsPa(i,end-prefix+1:end),ofdmSymbolsPa(i,:)];
end

len_symbol = NFFT+prefix;

ofdmSymbolsSe = reshape(ofdmSymbolsSended,1,(Nsym+prefix)*NFFT);

%The signal is multiplied by a carrier to move the frecuency to the desired
t = 0:1/Fs:(NFFT*(Nsym+prefix)-1)/Fs;
%Simulating DAC
% Interpolation of the signal
ofdmSymbolsSe = upsample(ofdmSymbolsSe,L);

% Vector of frecuencies for the dac
f_dac = linspace(-0.5,0.5,NFFT);

%Frecuency response for a non return to zero digital to analog convertion
dac_response = L/Fs.*sinc(1/Fs*f_dac);
ofdmSymbolsSe = ifft(fftshift(fft(ofdmSymbolsSe,NFFT).*dac_response));

% The signal is moved to the carrier frequency
imaginary_part = imag(ofdmSymbolsSe).*cos(2*pi*fc*t);
real_part = real(ofdmSymbolsSe).*sin(2*pi*fc*t);
ofdmSymbolsSe = real_part+imaginary_part;



end