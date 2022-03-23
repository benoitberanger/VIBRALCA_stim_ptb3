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
    
    % [ ER, RR, KL, SR ] = Common.PrepareRecorders( EP );
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = KL;
    % S.SR = SR;
    
    
    %% Prepare objects
    
    % [ QUESTION, YES, NO ] = PNEU.Prepare.Text;
    % [ CROSS             ] = PNEU.Prepare.Cross;
    % [ CURSOR            ] = PNEU.Prepare.Cursor;
    % [ RECT_YES, RECT_NO ] = PNEU.Prepare.Rect;
    
    
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
                
                % Fetch initialization data
                % switch S.InputMethod
                %     case 'Joystick'
                %         [newX, newY] = PNEU.QueryJoystickData( CURSOR.screenX, CURSOR.screenY );
                %     case 'Mouse'
                %         SetMouse(CURSOR.Xorigin,CURSOR.Yorigin,CURSOR.wPtr);
                %         [newX, newY] = PNEU.QueryMouseData( CURSOR.wPtr, CURSOR.Xorigin, CURSOR.Yorigin );
                % end
                
                % Initialize cursor position
                % CURSOR.Move(newX,newY);
                
                % CROSS.Draw
                % Screen('DrawingFinished',S.PTB.wPtr);
                % Screen('Flip',S.PTB.wPtr);
                
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
                
            case 'Rest' % -------------------------------------------------
                
                % CROSS.Draw
                % PNEU.UpdateCursor( CURSOR )
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                % Screen('DrawingFinished', S.PTB.wPtr);
                % lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                lastFlipOnset = WaitSecs('UntilTime', when);
                % SR.AddSample([lastFlipOnset-StartTime CURSOR.X CURSOR.Y])
                % Common.SendParPortMessage(EP.Data{evt,1});
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({[EP.Data{evt,1} '_CROSS'] lastFlipOnset-StartTime [] []});
                
                when = StartTime + EP.Data{evt+1,2} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
                while secs < when
                    
                    % CROSS.Draw
                    % PNEU.UpdateCursor( CURSOR )
                    
                    % Screen('DrawingFinished', S.PTB.wPtr);
                    % lastFlipOnset = Screen('Flip', S.PTB.wPtr);
                    % SR.AddSample([lastFlipOnset-StartTime CURSOR.X CURSOR.Y])
                    
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
                
                
            case {'A', 'B', 'C', 'D'} % --------------------------------------
                
                % onset_YES = [];
                % onset_NO  = [];
                
                % CROSS.Draw
                % PNEU.UpdateCursor( CURSOR )
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                % Screen('DrawingFinished', S.PTB.wPtr);
                % conditionFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                conditionFlipOnset = WaitSecs('UntilTime', when);
                
                % Send stim
                if strcmp(S.StimONOFF,'ON')
                    switch EP.Data{evt,1}
                        case 'Bone'
                            S.FTDI.Start(1);
                            fprintf('Started BONE   channel=1 stimulation \n')
                        case 'Tendon'
                            S.FTDI.Start(2);
                            fprintf('Started TENDON channel=2 stimulation \n')
                    end
                end
                
                % SR.AddSample([conditionFlipOnset-StartTime CURSOR.X CURSOR.Y])
                % Common.SendParPortMessage(EP.Data{evt,1});
                ER.AddEvent({EP.Data{evt,1} conditionFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({[EP.Data{evt,1} '_CROSS'] conditionFlipOnset-StartTime [] []});
                
                when = conditionFlipOnset + EP.Data{evt,3} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = conditionFlipOnset;
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
                        case 'A'
                            S.FTDI.Stop(1);
                            fprintf('Stopped A channel=1 stimulation \n')
                        case 'B'
                            S.FTDI.Stop(2);
                            fprintf('Stopped B channel=2 stimulation \n')
                        case 'C'
                            S.FTDI.Stop(3);
                            fprintf('Stopped C channel=3 stimulation \n')
                        case 'D'
                            S.FTDI.Stop(4);
                            fprintf('Stopped D channel=4 stimulation \n')
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
    
    % Close the audio device
    % PsychPortAudio('Close');
    
    % TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, SR, StartTime, StopTime );
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    % TaskData.BR = BR;
    % assignin('base','BR', BR)
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
