%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints declared
%Environment is cleaned
clc;close all force;clear;

NUMBER_ITERATIONS = 100;   % Initial aproach AJUST VALUE
%Constraints related to the OFDM signal

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
RECIEVER_POSITION = [10,0,0]; % Defining reciever coordinates

%Planes for simulation
TARGET1_POSITION = [0,0,10];
TARGET1_VELOCITY = [300,0,0];   %The reference point is the emitter

%Time which is forwarded on each iteration
%The time step is the integration time of the reciever
TIME_STEP = 250e-3; %Units in seconds 250ms

%% Variables declaration
i = 0;                    %Variable to iterate over the loops
signal_sended = [];       %Signal on the simulation enviroment  
TARGETS_POSITIONS = [TARGET1_POSITION];
TARGETS_VELOCITIES = [TARGET1_VELOCITY];

signal_emitter_target = [];
signal_target_reciever = [];
signal_sended_emitter=[];
signal_sended_target = [];

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
[Ofdm_signal,len_symbol,fs]=OFDMModV2(Fc,prefix);
% Number of samples "moved" on each iteration
N = fs*TIME_STEP;
N = 10;
%Initial biestatic range to calculate the doppler shift
%Initial_range = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2)+ sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2); 

while i< NUMBER_ITERATIONS    
    %The emitter sends the signal
    %One OFDM symbol is sended
    signal_sended_emitter = [Ofdm_signal(N*i+1:N*i+N),signal_sended_emitter];  
    
    %The positions os the targets are updated
    TARGET1_POSITION = TARGET1_POSITION + TARGET1_VELOCITY.*TIME_STEP;
    

    %The signal is atenuated through the channel
    %The signal is retarded throgh until it reaches the plane
    
    distance_emitter_target = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2 ...
    +(TARGET1_POSITION(3)-EMITTER_POSITION(3))^2);
    
    channel_coeficients = 0:1/fs:distance_emitter_target/3e8;
    channel_coeficients(end) = 1;
    channel_coeficients(1:end-1) = 0;
    h_emitter = dfilt.dffir(channel_coeficients);
    
    signal_emitter_target = [signal_sended_emitter,zeros(length(channel_coeficients)-length(signal_sended_emitter),1)];
    signal_emitter_delayed = filter(h_emitter,signal_emitter_target);
    
    if (length(channel_coeficients)- length(signal_sended_emitter))<=0
        signal_bounced = signal_emitter_delayed(1:end-N);
        signal_sended_emitter = signal_sended_emitter(1:end-N);   
        %The signal bounces of the plane
        %The doppler shift is calculated as de variation of biestatic range 
        %Post_range = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2)+ sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2); 
        %doppler_shift = (Post_range -Initial_range)/TIME_STEP*(Fc/3e8); % Hz
        doppler_shift = ((TARGET1_POSITION(1)-EMITTER_POSITION(1))*TARGET1_VELOCITY(1)+(TARGET1_POSITION(2)-EMITTER_POSITION(2))*TARGET1_VELOCITY(2)...
           +(TARGET1_POSITION(3)-EMITTER_POSITION(3))*TARGET1_VELOCITY(3))/sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2 ...
        +(TARGET1_POSITION(3)-EMITTER_POSITION(3))^2)+...
        ((TARGET1_POSITION(1)-RECIEVER_POSITION(1))*TARGET1_VELOCITY(1)+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))*TARGET1_VELOCITY(2)...
           +(TARGET1_POSITION(3)-RECIEVER_POSITION(3))*TARGET1_VELOCITY(3))/sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2 ...
        +(TARGET1_POSITION(3)-RECIEVER_POSITION(3))^2);
        %Initial_range = Post_range;

        %The doppler shift is applied to the signal
        signal_vector = 1:1:N;
        signal_bounced = signal_bounced.*exp((-1i*pi*doppler_shift*signal_vector)/N);
    end
    
    
    
    %The signal bounces off the plane
    distance_target_reciever = sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2 ...
    +(TARGET1_POSITION(3)-RECIEVER_POSITION(3))^2);
    
    channel_coeficients_reciever = 0:1/fs:distance_target_reciever/3e8;
    channel_coeficients_reciever(end) = 1;
    channel_coeficients_reciever(1:end-1) = 0;
    h_reciever = dfilt.dffir(channel_coeficients_reciever);
    signal_sended_target = [signal_bounced, signal_sended_target];
    signal_target_reciever = [signal_sended_target,zeros(length(channel_coeficients)-length(signal_sended_target),1)];
    signal_target_retarded = filter(h_reciever,signal_target_reciever);
    
    if (length(channel_coeficients)- length(signal_sended_target))<=0
        signal_analyze = signal_sended_target(1:end-N); 
        signal_sended_target = signal_sended_target(1:end-N); 
    end
    
    
    plotElement(tp,TARGET1_POSITION,TARGET1_VELOCITY,'Avion')
    i= i+1;
end