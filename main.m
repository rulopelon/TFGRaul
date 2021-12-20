%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints declared
%Environment is cleaned
clc;close all force;clear;
%% Loading global parameters for the simulation
parameters;

global NUMBER_ITERATIONS
global TIME_STEP %Time which is forwarded on each iteration
global EMITTER_POSITION
global TARGET1_POSITION
global TARGET1_VELOCITY
global RECIEVER_POSITION




%% Variables declaration

%Object to plot all the elements in the 
tp = theaterPlot('XLim',[-90,90],'YLim',[-90,90],'ZLim',[0,40]);

i = 0;                    %Variable to iterate over the loops
signal_sended = [];       %Signal on the simulation enviroment  
TARGETS_POSITIONS = [TARGET1_POSITION];
TARGETS_VELOCITIES = [TARGET1_VELOCITY];

signal_emitter_target = [];
signal_target_reciever = [];
signal_sended_emitter=[];
signal_sended_target = [];
% The channel between emitter and reciever
signal_emitter_reciever =[];

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
[Ofdm_signal,len_symbol,fs]=OFDMModV2();
% Number of samples "moved" on each iteration
N = fs*TIME_STEP;
%Initial biestatic range to calculate the doppler shift
%Initial_range = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2)+ sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2); 
% Initializing the channel of emitter-reciever values

distance_emitter_target = sqrt(sum((RECIEVER_POSITION-EMITTER_POSITION).^2));

% The coeficients of the emitter and the recievier are only calculated
% once, as the distance is constants constant
coeficients_emitter_reciever = 0:1/fs:distance_emitter_target/3e8;
coeficients_emitter_reciever(1:end-1) = 0;
coeficients_emitter_reciever(end) = 1;
h_emitter_reciever = dfilt.dffir(coeficients_emitter_reciever);

signal_emitter_reciever = zeros(length(coeficients_emitter_reciever),0);

while i< NUMBER_ITERATIONS    
    %The emitter sends the signal
    %One OFDM symbol is sended
    signal_sended_emitter = [Ofdm_signal(N*i+1:N*i+N),signal_sended_emitter];  
    
    % The signal is sended to the reciever 
    signal_emitter_reciever = [Ofdm_signal(N*i+1:N*i+N)',signal_emitter_reciever];
    signal_emitter_reciever = signal_emitter_reciever(1:end-N);
    % The signal is delayed 
    signal_emitter_reciever_delayed = filter(h_emitter_reciever,signal_emitter_reciever);
    signal_emitter_reciever_delayed = signal_emitter_reciever_delayed(1:end-length(h_emitter_reciever)-2);
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
    % The transient is eliminated
    signal_emitter_delayed = signal_emitter_delayed(1:end-length(h_emitter)-2);

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
    signal_target_retarded = signal_target_retarded(1:end-length(h_reciever)-2);  
        
    if (length(channel_coeficients)- length(signal_sended_target))<=0
        signal_analyze = signal_sended_target(1:end-N)+signal_emitter_reciever_delayed(end-N:end); 
        signal_sended_target = signal_sended_target(1:end-N); 
    else 
        signal_analyze = signal_emitter_reciever_delayed(end-N:end);
    end
    reciever(signal_analyze,fc)
    plotElement(tp,TARGET1_POSITION,TARGET1_VELOCITY,'Avion')
    i= i+1;
end