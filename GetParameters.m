function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
global S

if isempty(S)
    %     S.Environement = 'MRI';
    %     S.Side         = 'Left';
    %     S.Task         = 'MRI';
end


%% Echo in command window

EchoStart(mfilename)


%% Paths

% Parameters.Path.wav = ['wav' filesep];


%% Set parameters

%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz

% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
% % Prisma scanner @ CENIR
% Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
% Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
% Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
% Parameters.Video.SubjectDistance = 0.120; % m
% Parameters.Video.ScreenWidthM    = 0.040; % m
% Parameters.Video.ScreenHeightM   = 0.030; % m

Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.SizeRatio   = 0.07; % Size = ScreenWide *ratio
Parameters.Text.Font        = 'Arial';
Parameters.Text.Color       = [255 255 255]; % [R G B] ( from 0 to 255 )
Parameters.Text.ClickCorlor = [0   255 0  ]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%%%%
%   VIBRALCA   %
%%%%%%%%%%%%%%%

% Small cross at the center => @FixationCross
Parameters.Cross.ScreenRatio     = 0.10;          % ratio : dim   = ScreenHeight*ratio_screen
Parameters.Cross.lineWidthRatio  = 0.05;          % ratio : width = dim         *ratio_width
Parameters.Cross.Color           = [255 255 255]; % [R G B] ( from 0 to 255 )

% All texts => @Text
Parameters.Question.Content    = 'Sensation de mouvement ?';
Parameters.Question.Color      = Parameters.Text.Color;
Parameters.Question.Xpos       = 0.50;
Parameters.Question.Ypos       = 0.20;

Parameters.Yes     .Content    = 'Oui';
Parameters.Yes     .Color      = Parameters.Text.Color;
Parameters.Yes     .Xpos       = 0.25;
Parameters.Yes     .Ypos       = 0.50;
Parameters.Yes     .RectX      = 0.35;
Parameters.Yes     .RectY      = 0.70;
Parameters.Yes     .FrameColor = Parameters.Video.ScreenBackgroundColor/2;
Parameters.Yes     .Thickness  = 0.005;
Parameters.Yes     .FillColor  = Parameters.Video.ScreenBackgroundColor;

Parameters.No      .Content    = 'Non';
Parameters.No      .Color      = Parameters.Text.Color;
Parameters.No      .Xpos       = 1 - Parameters.Yes.Xpos;
Parameters.No      .Ypos       = Parameters.Yes.Ypos;
Parameters.No      .RectX      = Parameters.Yes.RectX;
Parameters.No      .RectY      = Parameters.Yes.RectY;
Parameters.No      .FrameColor = Parameters.Yes.FrameColor;
Parameters.No      .Thickness  = Parameters.Yes.Thickness;
Parameters.No      .FillColor  = Parameters.Yes.FillColor;

% Cursor => @Dot
Parameters.Cursor.DimensionRatio = 0.04;          % diameter = DimensionRatio*ScreenHeight
Parameters.Cursor.DiskColor      = [255 255 255]; % [R G B] ( from 0 to 255 )
Parameters.Cursor.FrameColor     = [0 0 0];       % [R G B] ( from 0 to 255 )
Parameters.Cursor.Ypos           = 0.60;


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
% Parameters.Keybinds.emulTTL_s_ASCII      = KbName('s');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');


%% Echo in command window

EchoStop(mfilename)


end