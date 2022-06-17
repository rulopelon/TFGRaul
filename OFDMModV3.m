function [ofdm_exit,ofdm_exit_2]=OFDMModV3(Nsym)
    % MODIFIED BY RAUL GONZALEZ in order to adapt the code to the DVB-T
    % standard
    % incluying scattered pilots
    % load parameters and constants
    load("variables.mat","NFFT","L","PREFIX","CARRIERS","M","nAM","reconstruction_filter","symbol_length_emitter","number_scatter_pilots")
    
    Len_prefix = NFFT*PREFIX;
    
    % The sample frequency is  going to be achieved like in a real environment
    % using a 10Mhz, and then interpolating filtering and decimating the signal
    
    %%
    alocation = zeros(symbol_length_emitter,Nsym);
    ofdm_exit_2 = [];
    
    %Continuous pilots are added to the OFDM signal
    [indexes, pilot_values]=getContinuousPilots();
    
    
    
    % Getting the reference sequence
    reference_sequence = getReferenceSequence();
    modes = [];
    j = 0;
    for iteration = 1:1:Nsym
        % The symbols are generated randomly
        % Symbols is the vector that will be transformed with the ifft   
        symbols = (randi(sqrt(nAM),NFFT,1)-1-(sqrt(nAM)-1)/2)+1i*(randi(sqrt(nAM),NFFT,1)-1-(sqrt(nAM)-1)/2);
        %symbols = zeros(NFFT,1);
        % Value defined by the standard alpha = 1
        %symbols = symbols./sqrt(42);
     
        % Deleting CARRIERS not used
        symbols(end-(NFFT-CARRIERS-1)/2 +1:end,:) = 0;
        symbols(1:(NFFT-CARRIERS-1)/2) =0;
    
   
        
        %Introducing continuous pilots
        for i = indexes
            symbols(i+(NFFT-CARRIERS-1)/2,1) = pilot_values(i+1);
        end

        % Scattered pilots vector
        scattered_pilots_vector =(0 + 3*rem(1,4) + 12*(0:CARRIERS));
        % Introducing the scattered pilots
        switch j
            case 0
                %Do nothing
            case 1
                % Add 3 to the scattered pilots vector
                scattered_pilots_vector =scattered_pilots_vector+3;
            case 2
                % Add 6 to the scattered pilots vector
                scattered_pilots_vector =scattered_pilots_vector+6;
            case 3
                % Add 9 to the scattered pilots vector
                scattered_pilots_vector =scattered_pilots_vector+9;
        end
        
        % Shifting the vector to match the DVB-T standard
        scattered_pilots_vector = scattered_pilots_vector+(NFFT-CARRIERS-1)/2;
        % Delete the values that exceed the last carrier index
        scattered_pilots_vector = scattered_pilots_vector(1:find(scattered_pilots_vector>CARRIERS+(NFFT-CARRIERS-1)/2));
        
        % Variable for the scattered pilots
        pilot  = 1;
        for carrier= 1:1:CARRIERS+(NFFT-CARRIERS-1)/2
            if carrier == scattered_pilots_vector(pilot) 
                symbols(carrier) = 4/3*2*(1/2-reference_sequence(carrier-(NFFT-CARRIERS-1)/2));
                pilot = pilot+1;
            end
        end
        
        % Deleting CARRIERS not used
        symbols(end-(NFFT-CARRIERS-1)/2 +1:end,:) = 0;
        symbols(1:(NFFT-CARRIERS-1)/2) =0;
    

        % Frequency symbols are transformed to time ofdm symbols
        ofdmSymbolsPa = ifft(ifftshift(symbols));
        % Cyclic prefix i added, each symbol is added N samples at the beginning,
        % from the N last samples 
    
        %Symbol prefix is added
        ofdmSymbolsSended= [ofdmSymbolsPa(end-Len_prefix+1:end,1);ofdmSymbolsPa];
    
        %Simulating DAC
        
        % The base Fs for the signal is 9.14e6 Hz, so we need to acomplish 10
        % Mhz as decimal frequencies cannot be achieved
        % Vector of frecuencies for the dac at 10Mhz
        % Interpolation of the signal
        ofdmSymbolsSe = interpolation(ofdmSymbolsSended,M);
        % The signal is filtered
        
        % Filtering the signal to eliminate not wanted frequencies caused by the interpolation
        ofdmSymbolsSe_processed = conv(ofdmSymbolsSe,reconstruction_filter,'same');
       
        %Decimation
        ofdmSymbolsSe = ofdmSymbolsSe_processed(1:L:length(ofdmSymbolsSe_processed));
        
        alocation(:,iteration) = ofdmSymbolsSe;
        ofdm_exit_2= [ofdm_exit_2,ofdmSymbolsSended.'];
        % Check if the pilot has exceeded the maximum value
        modes = [modes;j];
        if j==3
            j = 0;
        else
            j = j+1;
        end
        
    end
    ofdm_exit = alocation(:);




end