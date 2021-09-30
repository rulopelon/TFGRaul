function [modSymbols,Y_symbol]=OFDMDemod(ofdmSymbolsSe)

% function [modSymbols]=OFDMDemod(ofdmSymbolsSe)
%
%  - ofdmSymbolsSe . OFDM received symbols (in time-domain). It matches the
%  ModSymbolsSe of OFDMMod function
%
%  - modSymbols . Digitally-modulated symbols obtained after the OFDM
%  demodulation. The length of this vector has to be an integer number of
%  times Nf
%%

Nf = 10;
NFFT = 128;
DEBUG = false;

if nargin == 0 || DEBUG
    m_ary = 4;
    Fs = 30e3;
    Nsym = 10;
    nBitsPerSym = Nf*log2(m_ary);
    iBit = round(rand(nBitsPerSym*Nsym,1));
    hmod = comm.PSKModulator('ModulationOrder',m_ary,'SymbolMapping','gray','BitInput',true,'PhaseOffset',0);
    
    modSymbols = step(hmod,iBit);
    
    [ofdmSymbolsPa,ofdmSymbolsSe,ofdmSymbolsFreq]=OFDMMod(modSymbols);
    SNR = 10;
    ofdmSymbolsSe = awgn(ofdmSymbolsSe,SNR);
    hdemod = comm.PSKDemodulator('ModulationOrder',m_ary,'SymbolMapping','gray','BitOutput',true,'PhaseOffset',0);
    
end

if mod(length(ofdmSymbolsSe),NFFT)~=0
    error('ofdmSymbolsSe'' length must be an integer number of tines NFFT') ;
end

Nsym = length(ofdmSymbolsSe)/NFFT;

y_symbol = reshape(ofdmSymbolsSe,NFFT,Nsym);

Y_symbol = fft(y_symbol)/(NFFT/sqrt((Nf)*2));

simTx = ones(1,Nf); % Vector de 1's de ejemplo para ver la estructura del espectro
txFreq =[zeros(1,((NFFT/2)-Nf)/2) conj(fliplr(simTx))  zeros(1,((NFFT/2)-Nf)/2)  zeros(1,(((NFFT/2)-Nf)/2)+1)  simTx zeros(1,(((NFFT/2)-Nf)/2)-1)]; % Simbolo OFDM en la frecuencia de ejemplo
ind = find(txFreq == 1); %Extraigo las posiciones

yMod_symbols = Y_symbol(ind(length(ind)/2+1:end),:);

modSymbols = reshape((yMod_symbols) ,Nsym*Nf,1);

if nargin == 0 || DEBUG
    rxBits = step(hdemod,modSymbols);
    figure
    stem(xor(rxBits,iBit))
    title('Errores en recepcion')
    scatterplot(modSymbols)
    title('Simbolos Recibidos')
    
    figure
    f = linspace(-.5,.5,NFFT)*Fs;
    stem(f*1e-3,fftshift(abs(Y_symbol)))
end