function [wk] = correctPilots(len_seq)

wk = zeros(1,len_seq);
mem = (ones(1,11));
for i = 1:len_seq
    wk(i) = mem(1);
    mem(:) = [mem(2:end) bitxor(mem(1),mem(3))];
end