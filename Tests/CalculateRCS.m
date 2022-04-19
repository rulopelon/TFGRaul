%% Calculating the RCS of different planes to 
clc, clear,close all
%%
p = platform;
p.FileName = 't-44c pegasus.stl'; 
p.Units = 'cm';
figure
%show(p)


figure


mesh(p,'MaxEdgeLength',0.1)

az = 0:1:360;
el = 0;
figure 
rcs(h,306e6,az,el,'EnableGPU',1);