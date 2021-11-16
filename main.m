%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints declared
%Environment is cleaned
clc;close all force;clear;

NUMBER_ITERATIONS = 100;   % Initial aproach AJUST VALUE
%Constraints related to the OFDM signal

BITS = 2;                 % Number of bits used to cuantify the sended signal
NFFT = 8192;
L = 1;  % Interpolation on the DAC 

%Object to plot all the elements in the 
tp = theaterPlot('XLim',[-90,90],'YLim',[-90,90],'ZLim',[0,40]);
%Frecuency at which the stream of data is modulated
Fc = 36e6;
%Prefix of the OFDM modulation
prefix = 1/32;


%Defining the emitter and the reciever, UNITS ARE IN KM
% the origin is at [0,0,0]
EMITTER_POSITION = [0,0,0]; % The origin of coordinates is the emitter 
RECIEVER_POSITION = [10,10,0]; % Defining reciever coordinates

%Planes for simulation
TARGET1_POSITION = [5,5,10];
TARGET1_VELOCITY = [-10,10,0];   %The reference point is the emitter

%Time which is forwarded on each iteration
INTEGRATION_TIME = 250e-3; %Units in seconds 250ms

%% Variables declaration
i = 0;                    %Variable to iterate over the loops
signal_sended = [];       %Signal on the simulation enviroment  
TARGETS_POSITIONS = [TARGET1_POSITION];
TARGETS_VELOCITIES = [TARGET1_VELOCITY];


disp("All variables loaded and declared")
%% Elements added to 3d environment
%This environment is just to visualize data NOT FOR SIMULATION NOR EXTRACT
%DATA


%The emitter is plotted
plotElement(tp,EMITTER_POSITION,[0,0,0],'Emisor')
%The reciever is plotted
plotElement(tp,RECIEVER_POSITION,[0,0,0],'Receptor')

disp("3D environment created")
%% Main loop of the passive radar simulation
disp("The simulation starts")

%OFDM signal is codificated
[seq,len_symbol]=OFDMModV2(Fc,prefix);
%The frequency of the carrier of the signal is changed
% fft1 =abs(fft(seq,length(seq)));
% 
% figure
% plot(fft1)
% title("Frecuency of the signal sended");

while i< NUMBER_ITERATIONS    
    %The emitter sends the signal
    %One OFDM symbol is sended
    signal_sended = seq(NFFT*i+1:NFFT*i+NFFT);  
    
    %The positions os the targets are updated
    TARGET1_POSITION = TARGET1_POSITION + TARGET1_VELOCITY.*INTEGRATION_TIME;
    

    %The signal is atenuated through the channel
    %The signal bounces of the plane
    
    i= i+1;
end