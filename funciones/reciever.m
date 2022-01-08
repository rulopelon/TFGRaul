function  reciever(data)

global signal_buffer
global reference_buffer
global surveillance_buffer 
global BATCH_SIZE
global NUMBER_BATCHES

signal_buffer = [signal_buffer,data];
% The signal is divided on reference and surveillance
reference_signal = [];
surveillance_signal =[];

% The signal is demodulated to baseband

%Frame synchronism
%Equalization

%Data is appended to the stream
reference_buffer = [reference_buffer,reference_signal];
surveillance_buffer = [surveillance_buffer,surveillance_signal];

% if length(signal_buffer) >= BATCH_SIZE*NUMBER_BATCHES
%     % Forcing the numerb of samples to be a multiplier of the number of
%     % batches
%     surveillance_analyze =[];
%     reference_analyse = [];
%     
%     if mod(length(signal_buffer),BATCH_SIZE) ~=0
%         n_batches = fix(length(signal_buffer),BATCH_SIZE); % The number of full batches (integer) to use
%         reference_analyse = reference_buffer(1:(n_batches*BATCH_SIZE)+1,:);
%         surveillance_analyze = reference_buffer(1:(n_batches*BATCH_SIZE)+1,:); 
%         
%         % Buffers are updated
%         signal_buffer = signal_buffer((n_batches*BATCH_SIZE)+2:length(surveillance_buffer));
%         reference_buffer = reference_buffer((n_batches*BATCH_SIZE)+2:length(surveillance_buffer));
%         surveillance_buffer = surveillance_buffer((n_batches*BATCH_SIZE)+2:length(surveillance_buffer),1);
%     else
%         reference_analyse = reference_buffer;
%         surveillance_analyze = surveillance_buffer;
%         %Buffers are emptied
%         signal_buffer = [];
%         reference_buffer = [];
%         surveillance_buffer = [];
%     end 
%     % The signal is analysed and targets are detected
%     blockProcessing(reference_analyse,surveillance_analyze);
%     
%     
% end
end

