function CAFAnalysis(signal,reference,n_samples)
% function which calculates the correlation ambiguity function, in roder to
% know the correlation of the introduced signal with a referenced signal
% delayed n_samples number of samples and dopler shifted n_samples times
PLOT = false;
correlation_matrix  = [];

for k=1:1:n_samples
    dopler_shifted = reference.*exp(1i*k*2*pi/n_samples);
    [correlation,lags ]= xcorr(dopler_shifted,signal,n_samples);
    plot(real(correlation(n_samples+1:end,1)))
    correlation_matrix = [correlation_matrix,correlation(n_samples+1:end,1)];

end

if PLOT
   
    figure
    surf(real(correlation_matrix),'EdgeColor','none')
    xlabel('Frequency')
    ylabel('Samples')
    zlabel('Correlation')
    title("CAF representation")
end
 