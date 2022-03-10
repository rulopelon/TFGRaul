%% Code to test if symbol synchronization works properly
[signal,signal_reference] = OFDMModV2(20);
% synchronization
index = symbolSynchronization(signal_reference.');