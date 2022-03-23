function [ SequenceHighLow ] = Randomize01( nr0, nr1, chunkSize )

if nargin < 3
    chunkSize = [];
end

if ~isempty(chunkSize) && ( mod(nr0+nr1,chunkSize)~=0 )
    error('chunkSize must be a sub-multiple of nr0+nr1')
end

maxiter = 10000; % max value of the counter

iter = 0; % counter

if ~isempty(chunkSize)
    %% Chunk strategy
    
    SequenceHighLow = [];
    
    prevChunk = [];
    
    for chunk = 1 : (nr0 + nr1) / chunkSize / 2
        
        while iter < maxiter
            
            % --- Find a chunk of sequence ---
            while iter < maxiter
                
                iter = iter + 1;
                
                SequenceHighLow_chunk = Shuffle([zeros(1,chunkSize) ones(1,chunkSize)]);
                SequenceHighLow_chunk_str = regexprep(num2str(SequenceHighLow_chunk),' ','');
                
                if checkCondition(SequenceHighLow_chunk_str)
                    break
                end
                
            end
            
            % ---check if the found chunk sequence can be merged with final s---
            
            SequenceHighLow_tmp = [prevChunk SequenceHighLow_chunk];
            SequenceHighLow_tmp_str = regexprep(num2str(SequenceHighLow_tmp),' ','');
            
            if checkCondition(SequenceHighLow_tmp_str)
                break
            end
            
        end
        
        if iter >= maxiter
            warning('Try to use chunkSize to optimize randomization iterations')
            error('Randomizer problem : maxiter reached.')
        end
        
        SequenceHighLow = [SequenceHighLow SequenceHighLow_chunk]; %#ok<AGROW>
        prevChunk       = SequenceHighLow_chunk;
        
    end
    
else
    %% Brute strategy
    
    while iter < maxiter
        
        iter = iter + 1;
        SequenceHighLow = Shuffle([zeros(1,nr0) ones(1,nr1)]);
        SequenceHighLow_str = regexprep(num2str(SequenceHighLow),' ','');
        
        if checkCondition(SequenceHighLow_str)
            break
        end
        
    end
    
    if iter >= maxiter
        warning('Try to use chunkSize to optimize randomization iterations')
        error('Randomizer problem : maxiter reached.')
    end
    
end


%% Final chack

SequenceHighLow_str_final = regexprep(num2str(SequenceHighLow),' ','');
assert( checkCondition(SequenceHighLow_str_final) , 'Final sequence does not fit the conditons' )

fprintf('randomizer interations = %d \n', iter)


end % function

function result = checkCondition(seq_str)

% maximum 3x(0) or 3x(1) in a row, max 2x(01) or 2x(10) in a row
result = ~(any(regexp(seq_str,'000')) || any(regexp(seq_str,'111')) || any(regexp(seq_str,'0101')) || any(regexp(seq_str,'1010')));

end % function
