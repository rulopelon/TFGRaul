function [Q,B] = pcm_quan_enco(e,bitsize)
%function [Q,b] = pcm_quan_enco(e,bitsize)
% e : input to quantizer
% bitsize : encoder bit size
% Q : qunatazer output
% B : encoder output

if bitsize<4
  slen = length(e);
  D = 2^(-bitsize);
  switch bitsize
  case 3,
      for i=1:slen
         if e(i) < -3*D
	         Q(i) = -(7/2)*D;
   	      b(i,:) = [ 0 0 0 ]; 
      	elseif e(i) >= -3*D & e(i) < -2*D
         	Q(i) = -(5/2)*D;
         	b(i,:) = [ 0 0 1 ]; 
      	elseif e(i) >= -2*D & e(i) < -D
            Q(i) = -(3/2)*D;
	         b(i,:) = [ 0 1 0 ]; 
			elseif e(i) >= -D & e(i) < 0
      	   Q(i) = -(1/2)*D;
	         b(i,:) = [ 0 1 1 ]; 
   	   elseif e(i) >= 0 & e(i) < D
      	   Q(i) = (1/2)*D;
         	b(i,:) = [ 1 0 0 ]; 
	      elseif e(i) >= D & e(i) < 2*D
   	      Q(i) = (3/2)*D;
      	   b(i,:) = [ 1 0 1 ]; 
			elseif e(i) >= 2*D & e(i) < 3*D
   	      Q(i) = (5/2)*D;
      	   b(i,:) = [ 1 1 0 ]; 
	      elseif e(i) >= 3*D
   	      Q(i) = (7/2)*D;
      	   b(i,:) = [ 1 1 1 ]; 
         end
      end      
         
   case 2,
      for i=1:slen         
         if e(i) < -D
            Q(i) = -(3/2)*D;
	         b(i,:) = [ 0 0 ]; 
			elseif e(i) >= -D & e(i) < 0
      	   Q(i) = -(1/2)*D;
            b(i,:) = [ 0 1 ]; 
         elseif e(i) >= 0 & e(i) < D
            Q(i) = (1/2)*D;
	         b(i,:) = [ 1 0 ]; 
			elseif e(i) >= D 
      	   Q(i) = (3/2)*D;
	         b(i,:) = [ 1 1 ]; 
         end
      end      
         
   case 1,
      for i=1:slen         
         if e(i) < 0
            Q(i) = -(1/2)*D;
	         b(i,:) = [ 0 ]; 
			elseif e(i) >= 0
      	   Q(i) = (1/2)*D;
            b(i,:) = [ 1 ]; 
         end
      end      
   otherwise      
      fprintf('choose a bit size 1,2 or 3.\n');      
   end               
   b=b';
   B=b(:)';
else    
  [b0, b, bb] = dbc(e, bitsize);   
  [Q] = bdc(b0,b);   
  B = [b0 b];
end




