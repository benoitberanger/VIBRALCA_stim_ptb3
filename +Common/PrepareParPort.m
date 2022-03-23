function ParPortMessages = PrepareParPort
global S

%% On ? Off ?

switch S.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0)
        
    case 'Off'
        
end

%% Prepare messages


% fill here...
msg.Rest   = 1;

msg.Skin   = 2;
msg.Nerve  = 3;

msg.Bone   = 4;
msg.Tendon = 5;


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut

end % function
