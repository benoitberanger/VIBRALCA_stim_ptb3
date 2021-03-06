function [ EP , Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.OperationMode = 'Acquisition';
end


%% Paradigme

Parameters.RestDuration        = [6 10];  % second
Parameters.NrRepetitions       = 10;
Parameters.ActivityDuration    = 6;  % second

Parameters.ramp_time = 5.000; % seconds
Parameters.step_time = 0.100; % seconds

Parameters.valve_opening_min = 40; % highest value when the valve remains opened
Parameters.valve_opening_max = 80; % lowest value to have the valve fully opened

switch S.OperationMode
    case 'Acquisition'
        % pass
        
    case 'FastDebug'
        Parameters.RestDuration        = [0.5 1];  % second
        Parameters.NrRepetitions       = 2;
        Parameters.ActivityDuration    = 6;  % second
        
    case 'RealisticDebug'
        Parameters.RestDuration        = [0.5 1];  % second
        Parameters.NrRepetitions       = 2;
        Parameters.ActivityDuration    = 6;  % second
        
end




%% Randomization the trials
% Maximum 1 in a row

Parameters.ListOfConditions_str = {'extD', 'flexD', 'extG', 'flexG'};
Parameters.ListOfConditions_num = [    1 ,      2 ,     3 ,      4 ];

for rep = 1 : Parameters.NrRepetitions
    
    if rep == 1
        vect = Shuffle(Parameters.ListOfConditions_num);
    else
        shuffled = Shuffle(Parameters.ListOfConditions_num);
        while vect(end) == shuffled(1)
            shuffled = Shuffle(Parameters.ListOfConditions_num);
        end
        vect = [vect shuffled];
    end
    
end

Parameters.ConditionOrder_num = vect;
Parameters.ConditionOrder_str = Parameters.ListOfConditions_str(Parameters.ConditionOrder_num);

NrTrials = length(Parameters.ConditionOrder_num);


%% Randomize rest duration

all_rest = linspace(Parameters.RestDuration(1), Parameters.RestDuration(2),  NrTrials + 1 );
all_rest = Shuffle(all_rest);


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)','#Condition'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------




for evt = 1 : NrTrials
    
    name = Parameters.ConditionOrder_str{evt};
    idx  = Parameters.ConditionOrder_num(evt);
    EP.AddPlanning({ 'Rest' NextOnset(EP) all_rest(evt)               [] })
    EP.AddPlanning({ name   NextOnset(EP) Parameters.ActivityDuration idx })
    
end

EP.AddPlanning({ 'Rest' NextOnset(EP) all_rest(evt+1) [] })

% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',NextOnset(EP));


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot()
    EP.PlotHRF(1.5)
    
end


end % function