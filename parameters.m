clear

%% Parameters and variables used on the reciever

signal_buffer = [];
reference_buffer = [];
surveillance_buffer = [];
threshold = 0.15; 


%% Parameters used for the simulation environment

NUMBER_ITERATIONS = 100;   % Initial aproach AJUST VALUE
%The time step is the integration time of the reciever
TIME_STEP = 250e-3; %Units in seconds 250ms

%UNITS ARE IN KM the origin is at [0,0,0]
EMITTER_POSITION = [0,0,0]; % The origin of coordinates is the emitter 
RECIEVER_POSITION = [15,0,0]; % Defining reciever coordinates

%Targets for simulation
TARGET1_POSITION = [20,10,10];
TARGET1_VELOCITY = [50,0,0];   %The reference point is the emitter

PROPAGATION_VELOCITY = 3e8;

SNR  = 50; % Value in db

GAIN_EMITTER = 1.3e11; %In watts
GAIN_RECIEVER = 1.3e11; %In watts
%% Constraints related to the OFDM signal parameters defined by the standard
pilot_amplitude = 4/3; % There is no need to multiply this value as all the symbols are normalized
Fs = 10e6;
nAM = 64; % As the modulation used is a 64 QAM
NFFT = 8192;
PREFIX = 1/8;
prefix_length = PREFIX*NFFT;
Fc = 306e6;
CARRIERS = 6817;
Fs_used = 9.14e6;
L = 64;     
M = 70;  
% Symbol length whitout performing the samples frequency change
symbol_length = (PREFIX*NFFT+NFFT);
% Symbol_length after the interpolation and decimation
symbol_length_emitter =(PREFIX*NFFT+NFFT)*M/L;
% Reconstruction filter
reconstruction_filter = getFilter(L,M);

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


%% Parameters for the batch processing algorithm
delay_detected = 0;
doppler_detected = 0;
PLOT = false;    
% Time of each OFDM symbol
T_symbol= symbol_length/Fs;
% Samples that are analysed on each iteration
T_batch= 924e-6;
Vmax = 1/(2*T_batch);

% Number of batches that are "moved" on each iteration
Number_batches = ceil(TIME_STEP/T_batch);
%Size of the batch analyzed
BATCH_SIZE = ceil(T_batch*Fs_used);
BATCH_SIZE_SIMULATION = BATCH_SIZE*M/L;

% Muliplied by M and divided by L to get the number of samples at 10 Mhz
Samples_iteration_simulation = Number_batches*BATCH_SIZE_SIMULATION;
Samples_iteration = int64(Number_batches*BATCH_SIZE);
%BATCH_SIZE = int64(BATCH_SIZE);
% Number of OFDM symbols produced on each iteration
Nsym = ceil(Samples_iteration/symbol_length);
Nsym_simulation = ceil(Samples_iteration_simulation/symbol_length_emitter);
save("variables.mat")

