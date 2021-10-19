function filter_created = getFilter(M,L,Nfft)
    % IDEAL FILTER
    deltafd = Nfft^-1;
    % First index where the filter should be different than 0
    
    index = (1/(2*M))*(1/deltafd);
    filter_created =zeros(Nfft,1);
    filter_created((Nfft/2)-index:(Nfft/2)+index) = L;
    
    
end

