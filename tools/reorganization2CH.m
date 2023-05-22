function CH = reorganization2CH(CH, blockSize, binRes)
%% REORGANIZATION2CH
% Save gaps, overlaps-between and overlaps-within in the channel where it
% occured. For more than two talkers, the CH array shows which channel
% overlapped or "gapped" with the current channel. For only two channels,
% this function reorganizes the array so that events in the current
% channel occured for that channel. 
% Fx, CH{1}.overlapW is channel 1 overlapping within channel 2's turn. 
% If this function is not run, CH{1}.overlapW.channel will show which 
% channel overlapped the current channel.
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.0, January 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

% Save gaps belonging to CH in that CH's cell
temp = CH{1}.gap;
CH{1}.gap = CH{2}.gap;
CH{2}.gap = temp;

% Save overlaps-between belonging to CH in that CH's cell
temp = CH{1}.overlapB;
CH{1}.overlapB = CH{2}.overlapB;
CH{2}.overlapB = temp;

% Save overlaps-within belonging to CH in that CH's cell
temp = CH{1}.overlapW;
CH{1}.overlapW = CH{2}.overlapW;
CH{2}.overlapW = temp;

% Save IPUs after:
% CH2's utterances after FTO
[~,idx] = intersect(CH{2}.IPU.startIdx,CH{2}.gap.endIdx);
CH{2}.IPUafterGap.duration = CH{2}.IPU.duration(idx);
CH{2}.IPUafterGap.startIdx = CH{2}.IPU.startIdx(idx);
CH{2}.IPUafterGap.endIdx = CH{2}.IPU.endIdx(idx);
CH{2}.IPUafterGap.numData = numel(CH{2}.IPU.duration(idx));

[~,idx] = intersect(CH{2}.IPU.startIdx,CH{2}.overlapB.startIdx);
CH{2}.IPUafterOverlap.duration = CH{2}.IPU.duration(idx);
CH{2}.IPUafterOverlap.startIdx = CH{2}.IPU.startIdx(idx);
CH{2}.IPUafterOverlap.endIdx = CH{2}.IPU.endIdx(idx);
CH{2}.IPUafterOverlap.numData = numel(CH{2}.IPU.duration(idx));

% CH1's utterances after FTO
[~,idx] = intersect(CH{1}.IPU.startIdx,CH{1}.gap.endIdx);
CH{1}.IPUafterGap.duration = CH{1}.IPU.duration(idx);
CH{1}.IPUafterGap.startIdx = CH{1}.IPU.startIdx(idx);
CH{1}.IPUafterGap.endIdx = CH{1}.IPU.endIdx(idx);
CH{1}.IPUafterGap.numData = numel(CH{1}.IPU.duration(idx));

[~,idx] = intersect(CH{1}.IPU.startIdx,CH{1}.overlapB.startIdx);
CH{1}.IPUafterOverlap.duration = CH{1}.IPU.duration(idx);
CH{1}.IPUafterOverlap.startIdx = CH{1}.IPU.startIdx(idx);
CH{1}.IPUafterOverlap.endIdx = CH{1}.IPU.endIdx(idx);
CH{1}.IPUafterOverlap.numData = numel(CH{1}.IPU.duration(idx));

%% Convert bins to seconds 
nameTmp = fields(CH{1});

for n = 1:2 % 2 channels
  for i = 3:numel(nameTmp) % Ignore CHidx and CHarrayOffset
    CH{n}.(nameTmp{i}).duration = CH{n}.(nameTmp{i}).duration * binRes;
    % If outputting start and stop indices in seconds: 
    %CH{n}.(nameTmp{i}).startIdx = CH{n}.(nameTmp{i}).startIdx * binRes - (binRes - blockSize/2);
    %CH{n}.(nameTmp{i}).endIdx   = CH{n}.(nameTmp{i}).endIdx * binRes - (binRes - blockSize/2);    
  end
end