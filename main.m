%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints declared
%Environment is cleaned
clc;close all force;clear;

NUMBER_ITERATIONS = 10;   % Initial aproach AJUST VALUE

%Object to plot all the elements in the 
tp = theaterPlot('XLim',[-90,90],'YLim',[-90,90],'ZLim',[0,40]);

%Defining the emitter and the reciever, UNITS ARE IN KM
% the origin is at [0,0,0]
EMITTER_POSITION = [0,0,0]; % The origin of coordinates is the emitter 
RECIEVER_POSITION = [10,10,0]; % Defining reciever coordinates

%Planes for simulation
TARGET1_POSITION = [5,5,10];
TARGET1_VELOCITY = [-10,10,0];   %The reference point is the emitter

%% Variables declaration
i = 0;                    %Variable to iterate over the loops
signal_sended = [];       %Signal on the simulation enviroment  
TARGETS_POSITIONS = [TARGET1_POSITION];
TARGETS_VELOCITIES = [TARGET1_VELOCITY];
%% Elements added to 3d environment
%This environment is just to visualize data NOT FOR SIMULATION NOR EXTRACT
%DATA
%The emitter is plotted
plotElement(tp,EMITTER_POSITION,[0,0,0],'Emisor')
%The reciever is plotted
plotElement(tp,RECIEVER_POSITION,[0,0,0],'Receptor')

%% Main loop of the passive radar simulation
while i< NUMBER_ITERATIONS
    %The emitter sends the signal
    %The signal is atenuated through the channel
    %The signal bounces on the plane
    
    i= i+1;
end