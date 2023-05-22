function CH = CSC(CHarray, nTalkers, blockSize, binRes) 
%% Communicative State Classification (CSC)
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.0, January 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CSC algorithm works for four talkers. It expects an n-by-4 binary array 
% for voice activity detection. 
% If less than four talkers, the last column(s) is/are filled with zeroes. 
nTalkersAlgo = 4;
if nTalkers < nTalkersAlgo
  for j = 1 : nTalkersAlgo - nTalkers
  CHarray(:,nTalkers+j) = zeros(size(CHarray(:,j)));
  end
end

% To be able to determine who starts talking, each channel has to be 0 on
% the first sample. 
CHarray(1,:) = 0;

% Declare channel classes
for ii = 1:nTalkersAlgo
  CH{ii} = channelTurn(ii);
end
% 
% In future versions of the CSC, it will be able to work online. 
% CHarray will be filled up as data is collected, and CHarrayOffset will 
% indicate the current placement in CHarray. emptyBuffer will be a flag
% indicating whether the current buffer has been read to end. For now,
% CHarrayOffset and emptyBuffer will be set to 0. 
CHarrayOffset     = 0;
emptyBuffer       = 0;
%
% Initialize leaveSet to NaNs. LeaveSet is nTalkersAlgo^2 long and indica-
% tes at what index each of the nTalkersAlgo^2 states were left
leaveSet(1 : nTalkersAlgo^2) = NaN;
%
% Determine initial talker(s) and leave state index
[nextCHidx, nextCH, leaveSet] = determineStartCH(CHarray, leaveSet);
% 
% Initialize order of talkers. Whoever had the turn before is the first in
% the queue. 
preOrder = 1:nTalkersAlgo;
%
% 
while and(~emptyBuffer,~isempty(nextCH))
  nextCHqueue    = [];
  leaveSetQueue  = [];
  nextCHidxQueue = [];
  preOrderQueue  = [];

  if numel(nextCH) > 1
    for ii = 1:numel(nextCH)
      currentCH = nextCH; currentOrder = preOrder;
      preLeaveSet = leaveSet; [nextCHidxQueue(end+1), nextCHqueue{end+1}, leaveSetQueue(end+1,:), emptyBuffer, preOrderQueue(end+1,:)] = CH{nextCH(ii)}.takeTurn(CHarray, CHarrayOffset, nextCHidx, leaveSet, preOrder); 
    end  

    % Determine who ended up holding the turn for longest
    [nextCHidx,idx] = max(nextCHidxQueue);
    CHwin = nextCH(idx);

    % Delete turn from the ones that did not hold the turn the longest 
    delIdx = nextCH(nextCH ~= CHwin);
    for jj = 1:length(delIdx)
      CH{delIdx(jj)}.turn.numData = CH{delIdx(jj)}.turn.numData - 1;
      CH{delIdx(jj)}.turn.duration(end) = [];
      CH{delIdx(jj)}.turn.startIdx(end) = [];
      CH{delIdx(jj)}.turn.endIdx(end) = [];
    end

    nextCH = nextCHqueue{idx};
    leaveSet = leaveSetQueue(idx,:);
    preOrder = preOrderQueue(idx,:);   
    currentCH = currentCH(idx);

  else
   currentCH = nextCH; currentOrder = preOrder;
   preLeaveSet = leaveSet; [nextCHidx, nextCH, leaveSet, emptyBuffer, preOrder] = CH{nextCH}.takeTurn(CHarray, CHarrayOffset, nextCHidx, leaveSet, preOrder); 
   [preStateIdx, preState] = max(leaveSet);
  end

end
%
% Save the final turn
for jj = 1:numel(currentCH)
  idx = currentCH(jj);
  preCHidx = find(currentOrder == idx);
  CH{idx}.turn = CH{idx}.turn.addData(CH{idx}.IPU, preLeaveSet, leaveSet, CHarrayOffset, preOrder, preCHidx);
end

% Delete excess talkers 
delIdx = 1:nTalkersAlgo;
delIdx = delIdx(delIdx > nTalkers);
CH(delIdx) = [];

if nTalkers == 2
  CH = reorganization2CH(CH, blockSize, binRes);
end
end