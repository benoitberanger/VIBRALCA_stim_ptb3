function SendParPortMessage( message, duration )
global S

if strcmp( S.StimONOFF , 'ON' )
    
    % Send Trigger
    WriteParPort( message  );
    WaitSecs    ( duration );
    WriteParPort( 0        );
    % WriteParPort( S.ParPortMessages.(message) );
    % WaitSecs    ( S.ParPortMessages.duration  );
    % WriteParPort( 0                           );
    
end

end % function
