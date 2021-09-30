function [Q] = pcm_deco_quan(B,bitsize)
% function [Q,b] = pcm_deco_quan(b,bitsize)
% pcm decoder and quantizer
% bitsize : encoder bit size
% B : input to decoder from encoder ouput
% Q : qunatazer output

if bitsize<4
  b=B;
  slen = length(b);
  D = 2^(-bitsize);
  i = 0;
  for j=1:bitsize:slen
   mask=j:j+bitsize-1;
   i = i+1;
   switch bitsize
      case 3,
         if b(mask) == [ 0 0 0 ]
	         Q(i) = -(7/2)*D;
      	elseif b(mask) == [ 0 0 1 ]
            Q(i) = -(5/2)*D;
         elseif b(mask) == [ 0 1 0 ] 
            Q(i) = -(3/2)*D;
			elseif b(mask) == [ 0 1 1 ]
      	   Q(i) = -(1/2)*D; 
   	   elseif b(mask) == [ 1 0 0 ]
      	   Q(i) = (1/2)*D;         	 
	      elseif b(mask) == [ 1 0 1 ]
   	      Q(i) = (3/2)*D;      	    
			elseif b(mask) == [ 1 1 0 ]
   	      Q(i) = (5/2)*D;      	    
	      elseif b(mask) == [ 1 1 1 ]
   	      Q(i) = (7/2)*D;      	    
         end
         
      case 2,
         if b(mask) == [ 0 0 ]
            Q(i) = -(3/2)*D;	          
			elseif b(mask) == [ 0 1 ]
      	   Q(i) = -(1/2)*D;           
         elseif b(mask) == [ 1 0 ]
            Q(i) = (1/2)*D;	          
			elseif b(mask) == [ 1 1 ]
      	   Q(i) = (3/2)*D;	         
   	   end
         
      case 1,
         if b(mask) == [ 0 ]
            Q(i) = -(1/2)*D;	          
			elseif b(mask) == [ 1 ]
      	   Q(i) = (1/2)*D;
         end
      otherwise
         fprintf('choose a bit size 1,2 or 3.\n');
      end 
   end
   
else
  slen=length(B)
  i = 0;
  for j=1:bitsize:slen
     i = i + 1;
   mask=j:j+bitsize-1;
     bb = B(mask);
     b0 = bb(1);   
     b = bb(2:bitsize);   
     Q(i)=bdc(b0,b);   
  end
end


   
  
