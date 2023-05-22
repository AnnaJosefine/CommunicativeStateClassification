clc, clear, close all;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is a small tutorial on how to use the Communicative State 
% Classification (CSC) algorithm run by the functions in the tools folder.
%
% This script will: 1) Read two audio files of a pair in a conversation, 
% 2) perform Voice Activity Detection (VAD), and 3) perform CSC where 
% the pair's conversation will be categorized into overlaps-between, gaps, 
% overlaps-within, pauses, interpausal units (IPUs), and turns. 
%
% For an overview of the nomenclature, please refer to my PhD thesis:
% Sørensen, A. Josefine Munch. 2021. "The Effects of Noise and Hearing 
% Loss on Conversational Dynasics." DTU Health Technology. 
% https://findit.dtu.dk/en/catalog/615d73b4d9001d0143799332 
%
% The example recordings of a conversation used here are taken from:
% Sørensen, Anna Josefine, Fereczkowski, Michal, & MacDonald, Ewen Neale. 
% (2018, March 21). Task dialog by native-Danish talkers in Danish and 
% English in both quiet and noise. Zenodo. 
% https://doi.org/10.5281/zenodo.1204951
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.1, May 2023
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Init
dirTools = ['..' filesep 'tools'];
addpath(dirTools);

% Audio settings:
nTalkers = 2; % Number of talkers
filename = 'cond1_pair1_rep1_CH'; 

%% Voice Activity Detection 
% This VAD determines speech dominant windows based on the power of the
% signal and a specified threshold. If your recordings are noisy, you can
% use another VAD to create the binary voice activity array for the CSC.s
%
% VAD settings:
powerThreshold = 2.5e-7; % Power threshold for on/off voice activity 
blockSize      = 5e-3;   % Size of analysis window
blockSkip      = 4e-3;   % Skip between block. Overlap = blockSize - blockSkip
plotVAD        = true;   % Plot VAD with waveform for inspection 
%
for i_talker = 1 : nTalkers
  % Read audiofile:
  [signal(i_talker,:), Fs] = audioread([filename num2str(i_talker) '.wav']);
  
  % Perform VAD:
  [activityArray(i_talker,:), time(i_talker,:), on{i_talker}, off{i_talker}, ...
    tRes(i_talker)] = voiceActivityDetection(signal(i_talker,:), Fs, ...
    powerThreshold, blockSize, blockSkip, plotVAD);
end

%% Communicative State Classification
CH = CSC(activityArray', nTalkers, blockSize, blockSkip);

%% Inspection
% Now all indices and durations for gaps, overlaps-between and -within, 
% pauses, IPUs, and turns are saved in CH.
% To see results for talker 1, look in CH{1}:
CH{1}
% If you want to fx inspect overlaps-within (OWs):
CH{1}.overlapW
% - numData will show you the number of OWs
% - duration shows you the duration of the OWs
% - startIdx and endIdx shows the start and end indices in the activityArray
%   where the OW occured
% - channel can be ignored for two talkers

% FTOs:
% If you want to find durations of floor-transfer offsets (FTOs), they are 
% computed as overlaps-within with negative duration concatenated with gaps
% with positive durations as follows:
for i_talker = 1 : nTalkers
  FTO{i_talker} = [-CH{i_talker}.overlapB.duration ...
                   CH{i_talker}.gap.duration];
end
% Histogram of FTOs for talker 1:
figure
histogram(FTO{1}, binwidth = .2)
xlabel("Floor-transfer offset")

% Again, you can find the start and end indices of the events by
% inspecting for overlaps-between:
CH{i_talker}.overlapB.startIdx
CH{i_talker}.overlapB.endIdx
% and for gaps:
CH{i_talker}.gap.startIdx
CH{i_talker}.gap.endIdx
% These are the indices in the activityArray. If you look these indices up
% in the time array, you will get the time indices in seconds in the
% original recording. The resolution of each bin in the time array is tRes
time(i_talker,CH{i_talker}.gap.endIdx)


