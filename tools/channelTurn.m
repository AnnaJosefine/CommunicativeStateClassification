classdef channelTurn < handle
%% CHANNELTURN 
% A turn class has a set of conversational dynamics measures consisting 
% % of gaps, overlaps-between, overlaps-within, pauses, IPUs, and turns. 
% A turn class is specific for the talker. 
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.0, January 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

  properties
    CHidx                                                 % Specifies the channel index (corresponding to the speaker who has the turn)
    CHarrayOffset    = 0;                                 % Value is added to indices of CHarray  
    overlapW         = turnDataClass('overlapW');         % overlaps-within (overlaps within CH's speech stream)
    overlapB         = turnDataClass('overlapB');         % overlaps-between (overlaps between talkers during turn-taking)
    gap              = turnDataClass('gap');              % gaps (gaps between talkers during turn-taking)
    pause            = turnDataClass('pause');            % pauses (pauses in CH's speech stream not interrupted by any other talkers)
    IPU              = turnDataClass('IPU');              % inter-pausal units (speech streams excluding overlaps-within)
    IPUbeforeGap     = turnDataClass('IPUbeforeGap');     % inter-pausal units before gaps
    IPUbeforeOverlap = turnDataClass('IPUbeforeOverlap'); % inter-pausal units before overlaps-between
    IPUafterGap      = turnDataClass('IPUafterGap');      % inter-pausal units after gaps
    IPUafterOverlap  = turnDataClass('IPUafterOverlap');  % inter-pausal units after overlaps-between    
    turn             = turnDataClass('turn');             % turns (time in between turn-takings)
  end
  
  methods
    function obj = channelTurn(channelIdx)
      %TURN Create object for speaker turn
      %   channelIdx: specifies the index in the processed data set
      %   (truth table). This corresponds to the speaker who has the turn
      obj.CHidx = channelIdx;
    end
    
    function [i, nextCH, curLeaveSet, emptyBuffer, order] = ...
        takeTurn(obj, CHarray, CHarrayOffset, startCHIdx, preLeaveSet, preOrder)        
      
      % Rearrange CHarray so class perceives array similarly irrespective
      % of active channel:
      numCHarray = 1:size(CHarray,2);
      order = [obj.CHidx numCHarray(numCHarray ~= obj.CHidx)];
      CHarray = bi2de(CHarray(:,order));                                    % Rearrange and convert to decimal 
      
      % Sort curLeaveSet to match global idx   
      globalIdx = de2bi(0:15, 4);
      [~,sortIdx] = sort(order);
      withinIdx = bi2de(globalIdx(:, sortIdx));                        
      curLeaveSet = preLeaveSet(withinIdx + 1);
            
      % Init
      state = CHarray(startCHIdx);      
      preCHidx = find(preOrder == obj.CHidx);
     
      emptyBuffer = 0;
      
      for i = startCHIdx+1 : length(CHarray)     
        if CHarray(i - 1) ~= CHarray(i)                                     % Detect change between current and previous sample
                   
          curLeaveSet(state+1) = i;                                         % Save current leave state
          switch state
            
            case 0 % idle
              switch CHarray(i)
                case {1,3,5,7,9,11,13,15} % pause
                  obj.pause = obj.pause.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order);                           
                case 2 % IPUbeforeGap, turn, gap (CH2), return (CH2)          
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);         
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  nextCH = order(2);
                  return
                case 4 % IPUbeforeGap, turn, gap (CH3), return (CH3)           
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  nextCH = order(3);
                  return
                case 6 % IPUbeforeGap, turn, gap (CH2,3), return (CH2,3)          
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);         
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);      
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  nextCH = order([2 3]);
                  return
                case 8 % IPUbeforeGap, turn, gap (CH4), return (CH4)             
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order(4);
                  return
                case 10 % IPUbeforeGap, turn, gap (CH2,4), return (CH2,4)        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);      
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order([2 4]);
                  return
                case 12 % IPUbeforeGap, turn, gap (CH3,4), return (CH3,4)              
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);      
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order([3 4]);
                  return
                case 14 % IPUbeforeGap, turn, gap (CH2,3,4), return (CH2,3,4)                
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order([2 3 4]);
                  return
              end
              
            case 1 % activity
              switch CHarray(i)
                case {3,5,7,9,11,13,15} % overlap start
                case 0 % IPU
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                case 2 % IPU, IPUbeforeGap, turn, gap (CH2), return (CH2)        
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);            
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);      
                  nextCH = order(2);
                  return
                case 4 % IPU, IPUbeforeGap, turn, gap (CH3), return (CH3)        
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  nextCH = order(3);
                  return                  
                case 6 % IPU, IPUbeforeGap, turn, gap (CH2,3), return (CH2,3)         
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);     
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);  
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  nextCH = order([2 3]);
                  return
                case 8 % IPU, IPUbeforeGap, turn, gap (CH4), return (CH4)         
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);    
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order(4);
                  return                     
                case 10 % IPU, IPUbeforeGap, turn, gap (CH2,4), return (CH2,4)          
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order([2 4]);
                  return   
                case 12 % IPU, IPUbeforeGap, turn, gap (CH3,4), return (CH3,4)         
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);     
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order([3 4]);
                  return
                case 14 % IPU, IPUbeforeGap, turn, gap (CH2,3,4), return (CH2,3,4)       
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);           
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);       
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  nextCH = order([2 3 4]);
                  return                    
              end
              
            case 3
              switch CHarray(i)
                case {7,11,15}
                case 0 % IPU
                       % CH2: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                  
                case 1 % CH2: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                     
                case 2 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);            
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  nextCH = order(2);
                  return                    
      
                case 4 % IPU, IPUbeforeGap, turn
                       % CH2: overlapW 
                       % CH3: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);           
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);                 
                  nextCH = order(3);
                  return                    

                case 5 % CH2: overlapW                  
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);    

                case 6 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                       % CH2: overlapB, return
                       % CH3: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);       
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);                 
                  nextCH = order([2 3]);
                  return                    
                       
                case 8 % IPU, IPUbeforeGap, turn
                       % CH2: overlapW 
                       % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);              
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);             
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                  
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                       
                  nextCH = order(4);
                  return   
                       
                case 9 % CH2: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);           
                  
                case 10 % IPU,IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH2: overlapB, return
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order([2 4]);
                  return   
                  
                case 12 % IPU, IPUbeforeGap, turn
                        % CH2: overlapW
                        % CH3: gap, return
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);           
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);     
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);                    
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                                    
                  nextCH = order([3 4]);
                  return   
                        
                case 13 % CH2: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);    
                  
                case 14 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH2: overlapB, return
                        % CH3: gap, return
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                        
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx); 
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);                    
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order([2 3 4]);
                  return                     
              end
              
            case 5
              switch CHarray(i)
                case {7,13,15}

                case 0 % IPU
                       % CH3: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);                     
                       
                case 1 % CH3: overlapW      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  
                case 2 % IPU, IPUbeforeGap, turn
                       % CH2: gap, return
                       % CH3: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                 
                  nextCH = order(2);
                  return   
                       
                case 3 % CH3: overlapW      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  
                case 4 % IPU, IPUbeforeOverlap, turn
                       % CH3: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);            
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  nextCH = order(3);
                  return   
                       
                case 6 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                       % CH2: gap, return
                       % CH3: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                 
                  nextCH = order([2 3]);
                  return   
                       
                case 8 % IPU, IPUbeforeGap, turn
                       % CH3: overlapW
                       % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order(4);
                  return   
                       
                case 9 % CH3: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);   
                  
                case 10 % IPU, IPUbeforeGap, turn
                        % CH2: gap, return
                        % CH3: overlapW
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                    
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order([2 4]);
                  return   
                  
                case 11 % CH3: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);     
                  
                case 12 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH3: overlapB, return
                        % CH4: gap, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order([3 4]);
                  return   
                                          
                case 14 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                        % CH2: gap, return                        
                        % CH3: overlapB, return
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                        
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                      
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);                    
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order([2 3 4]);
                  return   
              end
                            
            case 7
              switch CHarray(i)
                case 0 % IPU
                       % CH2: overlapW
                       % CH3: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                       
                case 1 % CH2: overlapW
                       % CH3: overlapW       
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
 
                case 2 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapB, return
                       % CH3: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  nextCH = order(2);
                  return   
                  
                case 3 % CH3: overlapW       
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3); 
                  
                case 4 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapW
                       % CH3: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  nextCH = order(3);
                  return   
                  
                case 5 % CH2: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2); 
                  
                case 6 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapB, return
                       % CH3: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);                  
                  nextCH = order([2 3]);
                  return   

                case 8 % IPU, IPUbeforeGap, turn
                       % CH2: overlapW
                       % CH3: overlapW 
                       % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);              
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);   
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                 
                  nextCH = order(4);
                  return   
                       
                case 9 % CH2: overlapW
                       % CH3: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3); 
                       
                case 10 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH2: overlapB, return
                        % CH3: overlapW
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                   
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);     
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);          
                  nextCH = order([2 4]);
                  return   
                        
                case 11 % CH3: overlapW      
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                   
                case 12 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH2: overlapW
                        % CH3: overlapB, return
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);          
                  nextCH = order([3 4]);
                  return   
                  
                case 13 % CH2: overlapW
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2); 
                  
                case 14 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH2: overlapB, return
                        % CH3: overlapB, return
                        % CH4: gap, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);          
                  nextCH = order([2 3 4]);
                  return   
                        
                case 15 % otherwise
              end
              
            case 9
              switch CHarray(i)
                case {11,13,15}
                case 0 % IPU
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);      
                       
                case 1 % CH4: overlapW       
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4); 
                  
                case 2 % IPU, IPUbeforeGap, turn
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  
                case 3 % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  
                case 4 % IPU, IPUbeforeGap, turn
                       % CH3: gap, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order(3);
                  return   
                       
                case 5 % CH4: overlapW       
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4); 
                  
                case 6 % IPU, IPUbeforeGap, turn
                       % CH2: gap, return
                       % CH3: gap, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order([2 3]);
                  return   
                  
                case 7 % CH4: overlapW       
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4); 
                  
                case 8 % IPU, IPUbeforeOverlap, turn
                       % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order(4);
                  return   
                       
                case 10 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                        % CH2: gap, return
                        % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                      
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx); 
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  nextCH = order([2 4]);
                  return   
                                          
                case 12 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                        % CH3: gap, return
                        % CH4: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                      
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order([3 4]);
                  return   
                        
                case 14 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                        % CH2: gap, return
                        % CH3: gap, return
                        % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);          
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order([2 3 4]);
                  return   
              end
              
            case 11
              switch CHarray(i)
                case 0 % IPU
                       % CH2: overlapW 
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);           
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                    
                       
                case 1 % CH2: overlapW
                       % CH4: overlapW         
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 2 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapB, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                         
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);           
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  nextCH = order(2);
                  return   
                       
                case 3 % CH4: overlapW       
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4); 
                  
                case 4 % IPU, IPUbeforeGap, turn
                       % CH2: overlapW
                       % CH3: gap, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order(3);
                  return   
                       
                case 5 % CH2: overlapW 
                       % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 6 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                       % CH2: overlapB, return
                       % CH3: gap, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                        
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);  
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order([2 3]);
                  return   
                  
                case 7 % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  
                case 8 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapW
                       % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);              
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                      
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order(4);
                  return   
                  
                case 9 % CH2: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                       
                case 10 % IPU, IPUbeforeOverlap, turn
                        % CH2: overlapB, return
                        % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order([2 4]);
                  return   
                        
                case 12 % IPU, IPUbeforeOverlap, IPUbeforeGap, turn
                        % CH2: overlapW
                        % CH3: gap, return
                        % CH4: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                   
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);     
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order([3 4]);
                  return   
                        
                case 13 % CH2: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  
                case 14 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn 
                        % CH2: overlapB, return
                        % CH3: gap, return
                        % CH4: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);         
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);          
                  nextCH = order([2 3 4]);
                  return   
                        
                case 15 % otherwise
              end
              
            case 13
              switch CHarray(i)
                case 0 % IPU
                       % CH3: overlapW
                       % CH4: overlapW 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 1 % CH3: overlapW
                       % CH4: overlapW         
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 2 % IPU, IPUbeforeGap, turn
                       % CH2: gap, return
                       % CH3: overlapW
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                  
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  nextCH = order(2);
                  return   
                       
                case 3 % CH3: overlapW 
                       % CH4: overlapW         
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 4 % IPU, IPUbeforeOverlap, turn
                       % CH3: overlapB, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  nextCH = order(3);
                  return   
                       
                case 5 % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                   
                case 6 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                       % CH2: gap, return
                       % CH3: overlapB, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);              
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                         
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  nextCH = order([2 3]);
                  return   
                       
                case 7 % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  
                case 8 % IPU, IPUbeforeOverlap, turn
                       % CH3: overlapW
                       % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                    
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order(4);
                  return   
                       
                case 9 % CH3: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  
                case 10 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                        % CH2: gap, return
                        % CH3: overlapW
                        % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                               
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx); 
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  nextCH = order([2 4]);
                  return   
                        
                case 11 % CH3: overlapW         
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  
                case 12 % IPU, IPUbeforeOverlap, turn
                        % CH3: overlapB, return
                        % CH4: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                   
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                 
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order([3 4]);
                  return   
                        
                case 14 % IPU, IPUbeforeGap, IPUbeforeOverlap, turn
                        % CH2: gap, return
                        % CH3: overlapB, return
                        % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);   
                  obj.IPUbeforeGap = obj.IPUbeforeGap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  obj.gap = obj.gap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);          
                  nextCH = order([2 3 4]);
                  return   
                        
                case 15 % otherwise                 
              end 
              
            case 15
              switch CHarray(i)
                case 0 % IPU
                       % CH2: overlapW
                       % CH3: overlapW
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);           
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);                  
                        
                case 1 % CH2: overlapW
                       % CH3: overlapW
                       % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 2 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapB, return
                       % CH3: overlapW
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                        
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);            
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  nextCH = order(2);
                  return   
                       
                case 3 % CH3: overlapW
                       % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 4 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapW
                       % CH3: overlapB, return
                       % CH4: overlapW
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  nextCH = order(3);
                  return   
                       
                case 5 % CH2: overlapW
                       % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                       
                case 6 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapB, return
                       % CH3: overlapB, return
                       % CH4: overlapW 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);            
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                        
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  nextCH = order([2 3]);
                  return   
                       
                case 7 % CH4: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 4);
                  
                case 8 % IPU, IPUbeforeOverlap, turn
                       % CH2: overlapW
                       % CH3: overlapW
                       % CH4: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);            
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                        
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order(4);
                  return   
                       
                case 9 % CH2: overlapW
                       % CH3: overlapW         
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                       
                case 10 % IPU, IPUbeforeOverlap, turn
                        % CH2: overlapB, return
                        % CH3: overlapW
                        % CH4: overlapB, return 
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order([2 4]);
                  return   
                        
                case 11 % CH3: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 3);
                  
                case 12 % IPU, IPUbeforeOverlap, turn
                        % CH2: overlapW
                        % CH3: overlapB, return
                        % CH4: overlapB, return
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);               
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                     
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order([3 4]);
                  return   
                        
                case 13 % CH2: overlapW        
                  obj.overlapW = obj.overlapW.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, 2);
                  
                case 14 % IPU, IPUbeforeOverlap, turn
                        % CH2: overlapB, return
                        % CH3: overlapB, return
                        % CH4: overlapB, return         
                  obj.IPU = obj.IPU.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);             
                  obj.IPUbeforeOverlap = obj.IPUbeforeOverlap.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);                       
                  obj.turn = obj.turn.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx);     
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 2);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 3);
                  obj.overlapB = obj.overlapB.addData(obj.IPU, preLeaveSet, curLeaveSet, CHarrayOffset, order, preCHidx, 4);
                  nextCH = order([2 3 4]);
                  return   
              end
            
                       
          end % switch state
          state = CHarray(i); 

        end
      end % end reading channel array
      emptyBuffer = 1;
      
      % If two turns have been initialized at the same time, the next
      % channel is determined after the termination of both turns in main
      if ~exist('nextCH')
        nextCH = [];
      end
      
    end
  end
end

    
