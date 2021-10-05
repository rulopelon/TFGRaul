% Simple ambiguity function code

function amf = ambf(x, y)

% Work with input signals as column vectors
x = x(:);
y = y(:);

% length of the input sequence
xlen = length(x);
ylen = length(y);

% normalized input vectors
xnorm = x/sqrt(x'*x);
ynorm = y/sqrt(y'*y);

% size of the ambiguity function
seqlen = xlen+ylen;
tau = -(seqlen/2-1):(seqlen/2-1); % time delay vector
taulen = seqlen - 1; % convolution length
nfreq = 2^nextpow2(taulen); % normalization factor

% force input signals to be the same length by zero-padding to the right
if xlen>=ylen
    ynorm = [ynorm;zeros(xlen-ylen,1)];
else
    xnorm = [xnorm;zeros(ylen-xlen,1)];    
end
xlen = numel(xnorm);

% Ambiguity function initialization
amf = zeros(nfreq,taulen);

% Ambiguity function computation
for m = 1:taulen
    % Obtain a time shifted verion of xnorm
    v = zeros(xlen,1);
    if tau(m)>=0
        v(1:xlen-tau(m))=xnorm(tau(m)+1:xlen);
    else
        v(1-tau(m):xlen)=xnorm(1:xlen+tau(m));
    end
    amf(:,m) = abs(ifftshift(ifft(ynorm.*conj(v),nfreq)));
end

amf = nfreq*amf;