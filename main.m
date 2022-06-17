%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints declared
%Environment is cleaned
clc;close all force;clear;
%% Loading global parameters for the simulation
load("variables.mat","NUMBER_ITERATIONS","","EMITTER_POSITION", ...
    "TARGET1_POSITION","TARGET1_VELOCITY","RECIEVER_POSITION","BATCH_SIZE_SIMULATION", ...
    "Fs","Number_batches","Samples_iteration_simulation","Nsym_simulation","T_batch","PROPAGATION_VELOCITY", ...
    "Fc","SNR","GAIN_EMITTER","GAIN_RECIEVER","RADAR_CROSS_SECTION","POWER_TRANSMITED","LAMBDA","Samples_step")

%% Variables declaration

%Object to plot all the elements in the 
tp = theaterPlot('XLim',[-90,90],'YLim',[-90,90],'ZLim',[0,40]);

i = 0;                    %Variable to iterate over the loops

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

distance_emitter_reciever = sqrt(sum((RECIEVER_POSITION-EMITTER_POSITION).^2));
% Calculus of the losses
power_desired_emitter_reciever = POWER_TRANSMITED*(4*pi*distance_emitter_reciever^2);
% The coeficients of the emitter and the recievier are only calculated
% once, as the distance is constants constant
channel_coeficients_emitter_reciever = 0:1/Fs:(distance_emitter_reciever)/PROPAGATION_VELOCITY;
channel_coeficients_emitter_reciever(1:end-1) = 0;
channel_coeficients_emitter_reciever(end) = 1;



%% Iterations
 %OFDM signal is generated
while i< NUMBER_ITERATIONS    
    
    %load("OFDMSignal.mat")
    [Ofdm_signal ,~]= OFDMModV3(Nsym_simulation);
    % Controlling the power emited
    power_emitter = (1/length(Ofdm_signal))*sum(abs(Ofdm_signal).^2);
    % Calculating the coeficient to get the desired power transmited
    coeficient_emitter = POWER_TRANSMITED/power_emitter;
    % Correcting the transmitted power
    Ofdm_signal = sqrt(coeficient_emitter).*Ofdm_signal;

    distance_emitter_reciever = sqrt(sum((RECIEVER_POSITION-EMITTER_POSITION).^2));
    % Calculus of the losses
    power_desired_emitter_reciever = POWER_TRANSMITED/(4*pi*distance_emitter_reciever^2);
    % The coeficients of the emitter and the recievier are only calculated
    % once, as the distance is constants constant
    channel_coeficients_emitter_reciever = 0:1/Fs:(distance_emitter_reciever)/PROPAGATION_VELOCITY;
    channel_coeficients_emitter_reciever(1:end-1) = 0;
    channel_coeficients_emitter_reciever(end) = 1;

    % Calculating the baseline signal
    signal_emitter_reciever= conv(channel_coeficients_emitter_reciever,Ofdm_signal); 
    signal_emitter_reciever = signal_emitter_reciever(1:length(Ofdm_signal));
    %Setting the power of the baseline signal
    power_emitter_reciever = (1/length(signal_emitter_reciever))*sum(abs(signal_emitter_reciever).^2);
    coeficient_emitter_reciever = power_desired_emitter_reciever/power_emitter_reciever;
    signal_emitter_reciever = sqrt(coeficient_emitter_reciever).*signal_emitter_reciever;


    % Prealocating the vectors
    surveillance_signal = zeros(length(Ofdm_signal),1);
    elapsed_time = Samples_step/Fs;
    
    % Iterating over each step 
    for step = 1:1:length(Ofdm_signal)/Samples_step
        % Updating the position
        TARGET_POSITION = TARGET1_POSITION+TARGET1_VELOCITY*elapsed_time*(step-1);

        % Calculating the distances
        distance_emitter_target = sqrt(sum((TARGET_POSITION-EMITTER_POSITION).^2));
        distance_target_emitter = sqrt(sum((RECIEVER_POSITION-TARGET_POSITION).^2));

        % Time required for the samples in the step to travel the distance
        time_travel = (distance_target_emitter+distance_emitter_target)/PROPAGATION_VELOCITY;

        % Calculating the index of the bounced samples
        index_bounce = (time_travel*Fs);
        
        % See if the samples can be allocated
        if ceil(index_bounce)+(step-1)*Samples_step < length(surveillance_signal)
            bounced_signal = Ofdm_signal(1+(step-1)*Samples_step:step*Samples_step);
            surveillance_signal(ceil(index_bounce)+1+(step-1)*Samples_step:min(ceil(index_bounce)+Samples_step*step,length(Ofdm_signal)))=surveillance_signal(ceil(index_bounce)+1+(step-1)*Samples_step:min(ceil(index_bounce)+Samples_step*step,length(Ofdm_signal)))+bounced_signal(1:length(surveillance_signal(ceil(index_bounce)+1+(step-1)*Samples_step:min(ceil(index_bounce)+Samples_step*step,length(Ofdm_signal))))).*exp(-1j*2*pi*Fc*((distance_emitter_target+distance_target_emitter)/2)/PROPAGATION_VELOCITY);
        else 
            a = 1;

        end
        
    end
    %Updating positions
    TARGET1_POSITION = TARGET_POSITION;

    % Calculus of the losses
    distance_emitter_target = sqrt(sum((TARGET1_POSITION-EMITTER_POSITION).^2));
    distance_target_reciever  = sqrt(sum((RECIEVER_POSITION-TARGET1_POSITION).^2));

    power_recieved_desired = (POWER_TRANSMITED*RADAR_CROSS_SECTION*GAIN_EMITTER*GAIN_RECIEVER*LAMBDA^2)/((4*pi)^3*(distance_emitter_target)^2*(distance_target_reciever)^2);    
    %power_recieved_desired = 1e-15;
    % Calculus of the power recieved
    real_power_recieved = (1/length(surveillance_signal))*sum(abs(surveillance_signal).^2);
    coeficient_recieved_desired = power_recieved_desired/real_power_recieved;
    % Correcting the power
    surveillance_signal = surveillance_signal.*sqrt(coeficient_recieved_desired);
    

  
    
    % Noise is added
    %surveillance_signal = awgn(surveillance_signal,SNR,'measured');

   
    signal_analyze = signal_emitter_reciever+surveillance_signal;
    %Signal is sended to the reciever
    Reciever(signal_analyze);
    testBatchAtenuation(signal_emitter_reciever,surveillance_signal)
    %Adding the plane to the environment
    plotElement(tp,TARGET1_POSITION,TARGET1_VELOCITY,'Avion')
    


    %Removing used samples
    signal_emitter_reciever =[];
    signal_emitter = [];
    signal_sended_target = [];
    % Adding one iteration to the simulation
    i= i+1;
end