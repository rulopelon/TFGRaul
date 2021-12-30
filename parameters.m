%% Parameters for the batch processing algorithm
global BATCH_SIZE
global NFFT_BATCH_SIZE
global delay_detected
global doppler_detected
global PLOT

BATCH_SIZE = 300;
NFFT_BATCH_SIZE = 300;
delay_detected = 0;
doppler_detected = 0;
PLOT = false;    

%% Parameters and variables used on the reciever
global signal_buffer
global reference_buffer
global surveillance_buffer 
global NUMBER_BATCHES % Number of batches to analyse

signal_buffer = [];
reference_buffer = [];
surveillance_buffer = [];
NUMBER_BATCHES = 40;

%% Parameters used for the simulation environment
global NUMBER_ITERATIONS
global TIME_STEP %Time which is forwarded on each iteration
global EMITTER_POSITION
global TARGET1_POSITION
global TARGET1_VELOCITY
global RECIEVER_POSITION

NUMBER_ITERATIONS = 100;   % Initial aproach AJUST VALUE
%The time step is the integration time of the reciever
TIME_STEP = 250e-3; %Units in seconds 250ms
%UNITS ARE IN KM the origin is at [0,0,0]
EMITTER_POSITION = [0,0,0]; % The origin of coordinates is the emitter 
RECIEVER_POSITION = [100,0,0]; % Defining reciever coordinates

%Targets for simulation
TARGET1_POSITION = [0,0,10];
TARGET1_VELOCITY = [300,0,0];   %The reference point is the emitter

%% Constraints related to the OFDM signal parameters defined by the standard
global NFFT
global L % % Interpolating factor
global PREFIX %Prefix of the OFDM modulation
global Fc %Frecuency at which the stream of data is modulated
global CARRIERS % Number of non-silent carriers 
global Nsym     % Number of symbols generated each time OFDMModv2 is called
global pilot_cells  % Defined by the standard
global Fs_used 
global M    % Decimating factor

NFFT = 8192;
PREFIX = 1/32;
Fc = 36e6;
CARRIERS = 6816;
Nsym = 100;
Fs_used = 10e6;
L = 64;     
M = 70;     
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