%% Passive radar simulation
% Sensor Fusion and Tracking Toolbox
%% Constraints are defined
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

%% Variables are defined
i = 0;                    %Variable to iterate over the loops
signal_sended = [];       %Signal on the simulation enviroment  

%% Main loop of the passive radar simulation
while i< NUMBER_ITERATIONS
    %the emitter sends the first signal
    
    i= i+1;
end