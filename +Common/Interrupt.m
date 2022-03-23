function [ EXIT, StopTime ] = Interrupt( keyCode, ER, RR, StartTime )
global S

% % Escape ?
% [ ~ , secs , keyCode ] = KbCheck;

if keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
    
    % Flag
    EXIT = 1;
    
    % Stop time
    StopTime = GetSecs;
    
    % Record StopTime
    ER.AddStopTime( 'StopTime', StopTime - StartTime );
    RR.AddStopTime( 'StopTime', StopTime - StartTime );
    
    ShowCursor;
    Priority( 0 );
    
    fprintf( 'ESCAPE key pressed \n')
    
else
    
    EXIT = 0;
    StopTime  = [];
    
end

end % function
