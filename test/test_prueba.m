function test_prueba()
    %A random signal is generated
    x = rand(10000,1);
    assert(isequal(x,x));
    assert(~isequal(x,x));
end