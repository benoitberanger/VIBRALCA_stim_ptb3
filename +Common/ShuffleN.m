function [ out ] = ShuffleN( in, N )

out = [];

for i = 1 : N
    
    new = Shuffle(in);
    
    if i > 1
        while out(end) == new(1)
            new = Shuffle(in);
        end % while
    end
    
    out = [ out new ]; %#ok<AGROW>
    
end % for

end % function
