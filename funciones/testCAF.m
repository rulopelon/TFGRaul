% Script to test the Caf function 
fc =1e8;
prefix = 1/32;
[signal,len] = OFDMModV2(fc,prefix);
CAFAnalysis(signal(1,:),signal(1,:),length(signal))
