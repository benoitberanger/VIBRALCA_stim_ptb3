function [ TaskData ] = Task
global S

S.PTB.slack = 0.001;

try
    %% Tunning of the task
    
    [ EP, Parameters ] = PNEU.Planning;
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = KL;
    
    
    %% Prepare objects
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink;
    
    
    %% Go
    
    % Initialize some variables
    EXIT = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
                
            case 'Rest' % -------------------------------------------------
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                lastFlipOnset = WaitSecs('UntilTime', when);
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                
                when = StartTime + EP.Data{evt+1,2} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case {'extD', 'flexD', 'extG', 'flexG'} % --------------------------------------
                
                switch EP.Data{evt,1}
                    case  'extD'
                        channel = 1;
                    case 'flexD'
                        channel = 2;
                    case  'extG'
                        channel = 3;
                    case 'flexG'
                        channel = 4;
                end
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                conditionOnset = WaitSecs('UntilTime', when);
                ER.AddEvent({EP.Data{evt,1} conditionOnset-StartTime [] EP.Data{evt,4:end}});
                
                opening_vect = linspace(...
                    Parameters.valve_opening_min,...
                    Parameters.valve_opening_max,...
                    round(Parameters.ramp_time/Parameters.step_time));
                opening_vect = round(opening_vect);
                
                timestamp = conditionOnset;
                for idx = 1 : length(opening_vect)
                    
                    % Fetch keys
                    [keyIsDown, ~, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                    % Send stim
                    if strcmp(S.StimONOFF,'ON')
                        
                        S.FTDI.Start(channel, opening_vect(idx));
                        fprintf('Started  %s channel=%d stimulation, value=%02d \n', EP.Data{evt,1}, channel, opening_vect(idx))
                        timestamp = WaitSecs('UntilTime', timestamp + Parameters.step_time);
                        
                    end
                    
                end
                
                
                when = conditionOnset + EP.Data{evt,3} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = conditionOnset;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Stop stim
                if strcmp(S.StimONOFF,'ON')
                    switch EP.Data{evt,1}
                        case  'extD'
                            S.FTDI.Stop(1);
                            fprintf('Stopped  extD channel=1 stimulation \n')
                        case 'flexD'
                            S.FTDI.Stop(2);
                            fprintf('Stopped flexD channel=2 stimulation \n')
                        case  'extG'
                            S.FTDI.Stop(3);
                            fprintf('Stopped  extG channel=3 stimulation \n')
                        case 'flexG'
                            S.FTDI.Stop(4);
                            fprintf('Stopped flexG channel=4 stimulation \n')
                    end
                end
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if EXIT
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
catch err
    
    Common.Catch( err );
    
end

end % function
