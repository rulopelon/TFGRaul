%% Parameters for the batch processing algorithm
global BATCH_SIZE
BATCH_SIZE = 300;
global NFFT_BATCH_SIZE
NFFT_BATCH_SIZE = 300;
global delay_detected
delay_detected = 0;
global doppler_detected
doppler_detected = 0;

global PLOT
PLOT = true;    

%% Parameters and variables used on the reciever
global signal_buffer
global reference_buffer
global surveillance_buffer 
global NUMBER_BATCHES % Number of batches to analyse

signal_buffer = [];
reference_buffer = [];
surveillance_buffer = [];