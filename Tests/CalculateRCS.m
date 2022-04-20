%% Calculating the RCS of different planes to 
clc, clear,close all
%%
p = platform;
p.FileName = 'sphere1.stl'; 
p.Units = 'mm';
%figure
%show(p)


figure


mesh(p)

az = 0:1:360;
el = 0;
figure 
rcs(p,306e6,az,el,'EnableGPU',1);