function [actArr, t, on, off, tRes,power] = voiceActivityDetection(sig, Fs, varargin)
% VOICEACTIVITYDETECTION
%    Detects voice activity in the waveform "sig" by computing the squared
%    RMS level (power) in overlapping windows of 5 ms duration with 
%    1 ms overlap (unless otherwise specified), and determining speech 
%    dominant windows based on a power threshold.
%    Gaps shorther than 180 ms of duration are bridged in order to avoid 
%    mistaking stop plosives for pauses, and activity bursts shorter than 
%    70 ms will be removed as they are unlikely to origin from speech 
%    activity.
%    
%    Inputs:
%    - sig:      waveform of talker                           [1x* double] 
%    - fs:       sampling rate                                [1x1 double]
%    - varargin: 
%                1) energy threshold, default: 2.5e-7         [1x1 double]
%                2) blockSize in seconds, default: 5 ms       [1x1 double]
%                3) blockSkip in seconds, default: 4 ms       [1x1 double]
%                4) if true, the energy is plotted together
%                   with the binary activity array indicating 
%                   speech dominant or silence dominant
%                   windows, default: false                   [true/false]
%                5) Temporal threshold for bridging gaps in 
%                   VAD, default: 180 ms                      [1x1 double]
%    Outputs:
%    - actArr:   binary array indicating speech dominant (1)
%                or silence domaninant (0) windows.           [1x* logical]
%    - t:        time array with mid-points of each of the 
%                windows                                      [1x* double]
%    - on:       sample idx for activity onset                [1x* double]
%    - off:      sample idx for activity offset               [1x* double]
%    - tRes:     time resolution of each bin [s]              [1x1 double]
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.6, January 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INPUT CHECK

% Set default parameters
optargs = {2.5e-7 5e-3 4e-3 false 180e-3};
idx = find(~cellfun(@isempty,varargin));
for i = 1:numel(idx); optargs{idx(i)} = varargin{idx(i)}; end

% Place optional args in  variable names
[actThresh, blockSize, blockSkip, plotON, silThresh] = optargs{:};

% Validate number of input arguments
narginchk(2,7);

%% COMPUTE RMS OF THE SIGNAL
% Define analysis window
window    = round(Fs * blockSize);                                          % Window size in samples
nOverlap  = round(Fs * (blockSize - blockSkip));                            % Overlap in samples
tRes      = blockSkip;                                                      % Temporal resolution of each bin
  
% Compute RMS^2 = power
[buff,~] = buffer(sig,window,nOverlap,'nodelay');                           % 'nodelay': no zeros in the beginning, i.e. first bin is at blockSize/2
power    = rms(buff,1).^2;

% Time vector
timeVec      = 0 : 1/Fs : length(sig)/Fs - 1/Fs;
[buffTime,~] = buffer(timeVec,window,nOverlap,'nodelay');
t            = mean(buffTime,1);

%% ACTIVITY DETECTION
% Thresholds
burstThresh = 70e-3/tRes;                                                   % Threshold for small bursts that are unlikely to be speech
silThresh   = silThresh/tRes;                                               % Threshold for defining silent gaps

% Activity
actArr = power > actThresh;                                                 % Defining activity in channel (binary)

% Set first sample to zero to detect changes in case it's active from the
% beginning:
actArr(1)   = 0;
actArr(end) = 0;

% Bridge pauses with dur < 180 ms, remove bursts of speech with dur < 90 ms 
% and bursts of speech with RMS value smaller than the noise.
%  
% BRIDGE GAPS:
% 
[on, off] = detectChanges(actArr);
%
% Define gap duration
gapDuration = on(2:end) - off(1:end-1);   
%
% Remove pauses < 180 ms
for j = 1:length(gapDuration)
  if gapDuration(j) < silThresh     
    actArr( off(j) : on(j+1) ) = 1;
  end
end
%
% REMOVE IRRELEVANT BURSTS OF SPEECH:
%
% Detect changes after pauses are bridged
%
[on, off] = detectChanges(actArr);
%
% Define burst duration
burst = off-on;
%
for i = 1:length(burst)
  % Set bursts < 90 ms to zero
  if burst(i) < burstThresh 
    actArr( on(i) : off(i) ) = 0;

  % If the mean power of active portion is below 2*actThresh, set to zero
  elseif mean( power( on(i) : off(i) ) ) < 2*actThresh 
    actArr( on(i) : off(i) ) = 0;
  end
end

[on, off] = detectChanges(actArr);

%% PLOT AUDIO SIGNAL AND POWER WITH VAD ARRAY
if plotON
  
  % Time vector for original signal:
  tSig = 0 : 1/Fs : length(sig)/Fs - 1/Fs;
  
  % Change format of time vectors to m/s/ms
  tSig = seconds(tSig); tSig.Format = 'mm:ss.SS';
  tPlot = seconds(t); tPlot.Format = 'mm:ss.SS';
  
  % Plot raw signal, power, activity array and power threshold
  figure;
  plot(tSig,sig/max(sig)*max(power)/2,'Color',[0.8 0.8 0.8])
  hold on;
  plot(tPlot,power,'b','Linewidth',1);
  plot(tPlot,actArr*max(power)/4,'r','LineWidth',.8);
  plot([tPlot(1) tPlot(end)],[actThresh actThresh],'--r');
  
  legend({'Original signal','Power','VAI','Activity threshold'});
  ylabel('Power');
  xlabel('Time [mm:ss.sss]');

end

end

function [on, off] = detectChanges(actArr)

% Determine sign changes
signChange = diff([actArr(1) actArr]); % +1 on, -1: off

% Time indices of activity on and off
on  = find(signChange == 1);
off = find(signChange == -1);

% Define first and last sign change
[~,~,firstSgnCgn] = find(signChange,1,'first');
[~,~,lastSgnCgn]  = find(signChange,1,'last');

% Add "on" signal to beginning of array
if firstSgnCgn == -1
  on = [1 on];
end

% Add "off" signal to end of array
if lastSgnCgn == 1
  off = [off length(actArr)];
end

end

