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
global NFFT
global PREFIX
global BATCH_SIZE
global Fs
global Number_batches
global Samples_iteration 
global Nsym
global T_batch
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

%Initial biestatic range to calculate the doppler shift
%Initial_range = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2)+ sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2); 
% Initializing the channel of emitter-reciever values

distance_emitter_target = sqrt(sum((RECIEVER_POSITION-EMITTER_POSITION).^2));

% The coeficients of the emitter and the recievier are only calculated
% once, as the distance is constants constant
coeficients_emitter_reciever = 0:1/Fs:distance_emitter_target/3e8;
coeficients_emitter_reciever(2:end) = 0;
coeficients_emitter_reciever(1) = 1;

% The signal between the emitter and the reciever starts empty, with all
% zeros
signal_emitter_reciever = zeros(1,Number_batches);
%% Iterations

while i< NUMBER_ITERATIONS    
    %OFDM signal is generated
    Ofdm_signal = OFDMModV2(Nsym);
    
    %One time step is sended
    signal_sended_emitter = [Ofdm_signal,signal_sended_emitter];  
    
    % The signal is sended to the reciever via the bistatic line
    signal_emitter_reciever = [Ofdm_signal,signal_emitter_reciever];
     % The first indexes of the signal are deleted as the reciever has
    % already used them
    signal_emitter_reciever = signal_emitter_reciever(1:end-Samples_iteration);
       
    % The signal is delayed 
    signal_emitter_reciever_delayed = filter(coeficients_emitter_reciever,1,signal_emitter_reciever);  
   
    %The positions of the targets are updated
    TARGET1_POSITION = TARGET1_POSITION + TARGET1_VELOCITY.*TIME_STEP;
    

    %The signal is atenuated through the channel
    %The signal is retarded until it reaches the plane
    
    %Units on Km
    distance_emitter_target = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2 ...
    +(TARGET1_POSITION(3)-EMITTER_POSITION(3))^2);
    
    % Calculus of the channel between the emitter and the target
    channel_coeficients = 0:1/Fs:distance_emitter_target/3e8;
    channel_coeficients(1) = 1;
    channel_coeficients(2:end) = 0;
    
   
    signal_emitter_target_delayed = filter(channel_coeficients,1,signal_sended_emitter);   
     
    signal_bounced = [];
    
    bounced_samples =0;
    if distance_emitter_target<=((1/Fs)*length(signal_emitter_target_delayed))*3e8
        % There is a bounce
        % The number of batches bounced is calculated
        distance_batch = 3e8*T_batch;
        difference_distance = ((1/Fs)*length(signal_emitter_target_delayed))*3e8-distance_emitter_target;
        bounced_batches = ceil(difference_distance/distance_batch);
        
        if bounced_batches > Number_batches
            bounced_batches = Number_batches;
        end
        bounced_samples = bounced_batches*BATCH_SIZE;
        
        signal_bounced = signal_emitter_target_delayed(end-bounced_samples+1:end);
        signal_sended_emitter = signal_sended_emitter(1:end-bounced_samples);   
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
        signal_vector = 1:1:bounced_samples;
        signal_bounced = signal_bounced.*exp((-1i*pi*doppler_shift*signal_vector)/bounced_samples);
    end
    % The bounced signal is filled with zeros to match the samples analyzed
    % If there is no bounce, the channel is filled with zeros
    signal_bounced =[zeros(Samples_iteration-bounced_samples,1),signal_bounced];
    
    
    %The signal bounces off the plane
    distance_target_reciever = sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2 ...
    +(TARGET1_POSITION(3)-RECIEVER_POSITION(3))^2);
    
    % Calculus of the channel between the emitter and the target
    channel_coeficients_reciever = 0:1/Fs:distance_target_reciever/3e8;
    channel_coeficients_reciever(2:end) = 0;
    channel_coeficients_reciever(1) = 1;
    
    % Appending the signal to the target channel buffer
    signal_sended_target = [signal_bounced, signal_sended_target];
  
    % The signal is retarded
    signal_target_reciever_delayed = filter(channel_coeficients_reciever,1,signal_sended_target);
    
        
    if distance_target_reciever<=((1/Fs)*length(signal_target_reciever_delayed))*3e8
        signal_analyze = signal_target_reciever_delayed(end-Samples_iteration+1:end)+signal_emitter_reciever_delayed(end-Samples_iteration+1:end); 
        signal_sended_target = signal_sended_target(1:end-Samples_iteration); 
    else 
        signal_analyze = signal_emitter_reciever_delayed(end-Samples_iteration+1:end);
    end
    
    reciever(signal_analyze)
    plotElement(tp,TARGET1_POSITION,TARGET1_VELOCITY,'Avion')
    i= i+1;
end