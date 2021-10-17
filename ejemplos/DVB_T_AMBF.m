%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DVB-T signal generation
clc, clear, close all force;
T_SYMB  = 2048;         % Symbol period for 2K mode, 4096 samples for 4K mode or 8192 samples for 8K mode
K_MAX   = 1704;         % Maximum frequency channel index for 2K mode, remaining carriers are set to zero
GUARD   = T_SYMB/32;    % Duration of Guard interval (1/4, 1/8, 1/16, 1/32)
samples_retarded = 0;
% Random QPSK symbol on each carrier (uniformly distributed)
carrier_symbols = exp(1j*2*pi*(randi(4,T_SYMB,1))/4)*exp(1j*pi/4);
carrier_symbols(1:(T_SYMB-K_MAX)/2,:) = 0;
carrier_symbols(end-(T_SYMB-K_MAX)/2+1:end,:) = 0;

% OFDM modulation
ofdm_symbols    = ifft(ifftshift(carrier_symbols,1)); 
guard_interval  = ofdm_symbols(end-GUARD+1:end,:);
ofdm_signal     = [guard_interval; ofdm_symbols];
ofdm_signal     = ofdm_signal(:);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Ambiguity function computation

amf = ambf(ofdm_signal, ofdm_signal);
fd = ((0:(size(amf,1)-1))-size(amf,1)/2)/size(amf,1);
dt = (0:(size(amf,2)-1))-size(amf,2)/2;



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PLOTs

% zero doppler cut
f1 = figure();
a1 = axes();
plot(a1, dt, amf(size(amf,1)/2,:))
xlabel(a1,'\tau (samples)')
title(a1,'AF(f_d, \tau), f_d = 0 (Hz)')

% zero-delay cut
f2 = figure();
a2 = axes();
plot(a2, fd, amf(:,ceil(size(amf,2)/2)))
xlabel(a2,'f_d (normalized frequency)')
title(a2,'AF(f_d, \tau), \tau = 0 (samples)')


