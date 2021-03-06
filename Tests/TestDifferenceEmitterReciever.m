%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints declared
%Environment is cleaned
clc;close all force;clear;
%% Loading global parameters for the simulation
load("variables.mat","NUMBER_ITERATIONS","TIME_STEP","EMITTER_POSITION", ...
    "TARGET1_POSITION","RECIEVER_POSITION","BATCH_SIZE_SIMULATION", ...
    "Fs","Number_batches","Samples_iteration_simulation","Nsym_simulation","T_batch","PROPAGATION_VELOCITY", ...
    "Fc","SNR","GAIN_EMITTER","GAIN_RECIEVER","RADAR_CROSS_SECTION","POWER_TRANSMITED","LAMBDA")

%% Variables declaration

%Object to plot all the elements in the 
tp = theaterPlot('XLim',[-90,90],'YLim',[-90,90],'ZLim',[0,40]);

i = 0;                    %Variable to iterate over the loops
signal_sended = [];       %Signal on the simulation enviroment  


signal_emitter_target = [];
signal_target_reciever = [];
signal_sended_emitter=[];
TARGET1_VELOCITY = [0,300,0];


% The signal between the emitter and the reciever starts empty, with all
% zeros
 signal_emitter_reciever =[];
 signal_emitter = [];
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

%Initial biestatic range to calculate the doppler shift
% Initializing the channel of emitter-reciever values

distance_emitter_reciever = sqrt(sum((RECIEVER_POSITION-EMITTER_POSITION).^2));
% Calculus of the losses
losses_emitter_receiver = ((4*pi*distance_emitter_reciever*1000)/(LAMBDA))^2;

% The coeficients of the emitter and the recievier are only calculated
% once, as the distance is constants constant
channel_coeficients_emitter_reciever = 0:1/Fs:(distance_emitter_reciever*1000)/PROPAGATION_VELOCITY;
channel_coeficients_emitter_reciever(1:end-1) = 0;
channel_coeficients_emitter_reciever(end) = 1/sqrt(losses_emitter_receiver);



%% Iterations
 %OFDM signal is generated
while i< NUMBER_ITERATIONS    
    
    load("OFDMSignal.mat")
    %[Ofdm_signal ,~]= OFDMModV2(Nsym_simulation);
    % Controlling the power emited
    power_emitter = (1/length(Ofdm_signal))*sum(abs(Ofdm_signal).^2);
    coeficient = POWER_TRANSMITED/power_emitter;
    % Correcting the transmitted power
    Ofdm_signal = sqrt(coeficient).*Ofdm_signal;

    % Calculating the coeficient to get the desired power transmited
    %One time step is sended
    signal_emitter = [signal_emitter;Ofdm_signal];  
    signal_emitter_sended = signal_emitter(1:int64(Samples_iteration_simulation));
    
    % The signal is sended to the reciever via the bistatic line
    signal_emitter_reciever = [signal_emitter_reciever;Ofdm_signal];
     % The first indexes of the signal are deleted as the reciever has
    % already used them
    signal_emitter_reciever_sended = signal_emitter_reciever(1:int64(Samples_iteration_simulation));
       
    % The signal is delayed 
    signal_emitter_reciever_delayed = conv(channel_coeficients_emitter_reciever,signal_emitter_reciever_sended);  
    % Noise is added
    %signal_emitter_reciever_delayed = awgn(signal_emitter_reciever_delayed,SNR,'measured');
 
    

    %The signal is retarded until it reaches the plane
    
    %Units on Km
    distance_emitter_target = sqrt((TARGET1_POSITION(1)-EMITTER_POSITION(1))^2+(TARGET1_POSITION(2)-EMITTER_POSITION(2))^2 ...
    +(TARGET1_POSITION(3)-EMITTER_POSITION(3))^2);
    

    % Calculus of the channel between the emitter and the target
    channel_coeficients_emitter_target = 0:1/Fs:(distance_emitter_target*1000)/PROPAGATION_VELOCITY;
    channel_coeficients_emitter_target(1:end-1) = 0;
    channel_coeficients_emitter_target(end) = 1;  
    
    % Signal is delayed
    signal_emitter_target_delayed = conv(channel_coeficients_emitter_target,signal_emitter_sended);   
    %Noise is added
    %signal_emitter_target_delayed = awgn(signal_emitter_target_delayed,SNR,'measured');
    signal_bounced_shifted = [];
    
    bounced_samples =0;
    if distance_emitter_target<=((1/Fs)*length(signal_emitter_target_delayed))*PROPAGATION_VELOCITY
        % There is a bounce
        % The number of batches bounced is calculated
        distance_batch = PROPAGATION_VELOCITY*T_batch;
        difference_distance = ((1/Fs)*length(signal_emitter_target_delayed))*PROPAGATION_VELOCITY-distance_emitter_target;
        bounced_batches = ceil(difference_distance/distance_batch);
        
        if bounced_batches > Number_batches
            bounced_batches = Number_batches;
        end
        bounced_samples = bounced_batches*BATCH_SIZE_SIMULATION;
        
        signal_bounced = signal_emitter_target_delayed(1:int64(bounced_samples));
        %The signal bounces of the plane
        % Calculating the doppler shift with the projected velocity on the bistatic vector    
        velocity_vector = [TARGET1_VELOCITY(1),TARGET1_VELOCITY(2)];
        % The angle beetwen both vectors
        alfa = acos(dot(velocity_vector,[1,0])/(norm(velocity_vector)*norm([1,0])));
        % Checking the sign of the velocity
        projected_velocity = cos(alfa)*norm(velocity_vector);
         if TARGET1_POSITION(1)> RECIEVER_POSITION(1)
            projected_velocity = -1*projected_velocity;
        end
        doppler_shift = (Fc*(1-PROPAGATION_VELOCITY/(PROPAGATION_VELOCITY-projected_velocity)));
        %The doppler shift is applied to the signal
        signal_vector = 0:1:bounced_samples-1;
        doppler_shift = doppler_shift/Fs;
        signal_bounced_shifted = signal_bounced.*exp(-1i*2*pi*doppler_shift*double(signal_vector).');
    end
    % The bounced signal is filled with zeros to match the samples analyzed
    % If there is no bounce, the channel is filled with zeros
    signal_bounced_shifted =[signal_bounced_shifted;zeros(int64(Samples_iteration_simulation-bounced_samples),1)];
    signal_emitter_reciever_delayed =[signal_emitter_reciever_delayed,zeros(Samples_iteration_simulation-length(signal_emitter_reciever_delayed),1)];
    
    %The signal bounces off the plane
    distance_target_reciever = sqrt((TARGET1_POSITION(1)-RECIEVER_POSITION(1))^2+(TARGET1_POSITION(2)-RECIEVER_POSITION(2))^2 ...
    +(TARGET1_POSITION(3)-RECIEVER_POSITION(3))^2);
    


    % Calculus of the channel between the emitter and the target
    channel_coeficients_reciever = 0:1/Fs:(distance_target_reciever*1000)/PROPAGATION_VELOCITY;
    channel_coeficients_reciever(1:end-1) = 0;
    %losses_target = 5e11;
    %channel_coeficients_reciever(end) = 1/sqrt(losses_target);
    channel_coeficients_reciever(end) = 1;
    % Appending the signal to the target channel buffer
    signal_sended_target = [signal_sended_target,signal_bounced_shifted];
    % The signal is retarded
    signal_target_reciever_delayed = conv(channel_coeficients_reciever,signal_sended_target);
    
    % Calculus of the losses
    db_relation = 100;
    natual_units_relation = 10^(40/10);
    
    % Calculus of the power recieved
    real_power_recieved = (1/length(signal_target_reciever_delayed))*sum(abs(signal_target_reciever_delayed).^2);
    real_power_recieved_db = 20*log10(real_power_recieved);
    power_transmited_db = 20*log10(POWER_TRANSMITED);
    power_recieved_desired_db = power_transmited_db-db_relation;
    power_recieved_desired = 10^(power_recieved_desired_db/10);
    coeficient = power_recieved_desired/real_power_recieved;
    % Correcting the power
    signal_target_reciever_delayed = signal_target_reciever_delayed.*sqrt(coeficient);
    

  
    
    % Noise is added
    signal_target_reciever_delayed = awgn(signal_target_reciever_delayed,SNR,'measured');

    % Deleting the used samples
    signal_sended_target= signal_sended_target(int64(Samples_iteration_simulation):end);
    signal_emitter_reciever = signal_emitter_reciever(int64(Samples_iteration_simulation):end);
    % The signal to analyze is the sum of the bistatic line signal and the
    % bounced signal from the plane
    signal_analyze =signal_emitter_reciever_delayed(1:int64(Samples_iteration_simulation))+signal_target_reciever_delayed(1:int64(Samples_iteration_simulation)); 
    
    %Signal is sended to the reciever
    Reciever(signal_analyze);
    %testBatchAtenuation(signal_emitter_reciever_delayed(1:int64(Samples_iteration_simulation)),signal_target_reciever_delayed(1:int64(Samples_iteration_simulation)))
    %Adding the plane to the environment
    plotElement(tp,TARGET1_POSITION,TARGET1_VELOCITY,'Avion')
    
    %The positions of the targets are updated
    TARGET1_POSITION = TARGET1_POSITION + TARGET1_VELOCITY.*TIME_STEP;

    %Removing used samples
    signal_emitter_reciever =[];
    signal_emitter = [];
    signal_sended_target = [];
    % Adding one iteration to the simulation
    i= i+1;
end