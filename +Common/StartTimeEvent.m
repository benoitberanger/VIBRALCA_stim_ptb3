function StartTime = StartTimeEvent
global S

switch S.OperationMode
    case 'Acquisition'
        HideCursor(S.ScreenID)
    case 'FastDebug'
    case 'RealisticDebug'
    otherwise
end

% Synchronization
StartTime = WaitForTTL;

end % function
