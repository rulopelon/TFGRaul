function [sqnr,m_quan,code]=uniform_pcm(m_samp,L)
global q
%UNIFORM_PCM    uniform PCM encoding of a sequence
%               [sqnr,m_quan,code]= uniform_pcm(m_samp,L)
%               m_samp   = input sampled sequence.
%               L        = number of quantization levels (even).
%               sqnr     = output SQNR (in dB).
%               m_quan   = quantized output before encoding.
%               idx_quan = index of quantized output.
%               code     = the encoded output.
 
m_max    = max(abs(m_samp));     % Find the maximum value of m_samp.  
m_quan   = m_samp/m_max;         % Normalizing m_samp.
idx_quan = m_quan;               % Quantization index.
delta    = 2/L;                  % Quantization step.
q        = delta.*[0:L-1];       % Define quantization regions.
q        = q-((L-1)/2)*delta;    % Centralize all quantization levels
                                 % around the x-axis.
 
for i=1:L
  m_quan(find((q(i)-delta/2 <= m_quan) & (m_quan <= q(i)+delta/2)))=...
  q(i).*ones(1,length(find((q(i)-delta/2 <= m_quan) & ...
  (m_quan <= q(i)+delta/2))));
  idx_quan(find(m_quan==q(i)))=(i-1).*ones(1,length(find(m_quan==q(i))));
end
 
m_quan;
idx_quan;
 
m_quan = m_quan * m_max;    % Release normalization for quantized values.                   
R      =ceil(log2(L));      % Define no. of bits per codeword.
code   = de2bi(idx_quan', R, 'left-msb'); % Generate codewords.
sqnr   = 20 * log10(norm(m_samp)/norm(m_samp - m_quan)); % Estimate SQNR.
