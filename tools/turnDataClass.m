classdef turnDataClass
%% TURNDATACLASS
% This class is used to add start index, end index and duration of 
% conversational events.
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.0, January 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  properties
    numData = 0
    type
    duration
    startIdx
    endIdx 
    channel = []
  end
  
  methods
    function obj = turnDataClass(type)
      %TURNDATACLASS Construct an instance of this class
      obj.type = type;  
    end
    
    function obj = addData(obj,IPUobj,preLeaveSet,curLeaveSet,offset,order,varargin)
      %ADDDATA Adds start index, end index and duration of gaps, overlaps-
      % within, overlaps-between, pauses, IPUs and IPUs preceeding either 
      % gaps or overlaps.
      %
      %   Input:
      %     - IPUobj: object holding IPUs. Used to save IPUs preceeding
      %               turn-takings.
      %     - curLeaveSet & preLeaveSet: 
      %               structs holding indices for when the following states 
      %               were left:
      %                  .idle(previous,current)
      %                  .activity(previous,current)
      %                  .overlap(previous,current)
      %
      %     - offset: indicates current placement in CHarray. Only used 
      %               when code is running online [not implemented yet].
      %     - order:  order of channels in the queue. The order is 
      %               determined by the order of onsets of speech from 
      %               the various talkers.
      %

      if nargin < 7
        obj.channel = [];
      else 
        CH = varargin{1};
      end
      
      if strcmp(obj.type,'overlapB')
        if length(varargin) < 2
          error('Overlapping channel missing')
        elseif length(varargin) == 2
          preCH = varargin{1};
          CH    = varargin{2};
        end
      end

      obj.numData = obj.numData + 1;
            
      stateIdx = {0 + 1;             % 
                 [0 1 5 9 13] + 1;   % CH2
                 [0 1 3 9 11] + 1;   % CH3
                 [0 1 3 5 7] + 1};   % CH4
        
      switch obj.type
        case 'overlapB'
          startIdxArr = [curLeaveSet(stateIdx{CH}) preLeaveSet(stateIdx{order(1)})];
          if max(preLeaveSet(stateIdx{preCH})) > max(startIdxArr)
            obj.numData = obj.numData - 1;
            return
          end
          endIdxArr   = curLeaveSet;
          obj.channel(obj.numData) = order(CH);
          
        case 'overlapW'
          startIdxArr = [curLeaveSet(stateIdx{CH}) preLeaveSet(stateIdx{order(1)})];
          endIdxArr   = curLeaveSet;
          obj.channel(obj.numData) = order(CH);
          
        case 'gap'
          startIdxArr = curLeaveSet([1 3 5 7 9 11 13 15] + 1);
          endIdxArr   = curLeaveSet;
          obj.channel(obj.numData) = order(CH);     
          
        case 'pause'
          startIdxArr = curLeaveSet([1 3 5 7 9 11 13 15] + 1);
          endIdxArr   = curLeaveSet;
          
        case 'IPU'
          startIdxArr = [curLeaveSet(stateIdx{1}) preLeaveSet(stateIdx{CH})];
          endIdxArr   = curLeaveSet([1 3 5 7 9 11 13 15] + 1);
          
        case {'IPUbeforeGap','IPUbeforeOverlap'}
%           obj.startIdx(obj.numData) = IPUobj.startIdx(IPUobj.numData);
%           obj.endIdx(obj.numData)   = IPUobj.endIdx(IPUobj.numData);
%           obj.duration(obj.numData) = IPUobj.duration(IPUobj.numData);
          return % Don't calculate duration, start indices and end indices 
          
        case 'turn' 
          startIdxArr = preLeaveSet(stateIdx{CH});
          endIdxArr   = curLeaveSet([1 3 5 7 9 11 13 15] + 1);
      end
      
      % Determine start and end indices
      startIndex = max(startIdxArr) + offset;
      endIndex   = max(endIdxArr) + offset;

      obj.startIdx(obj.numData) = startIndex;
      obj.endIdx(obj.numData)   = endIndex;
      obj.duration(obj.numData) = endIndex - startIndex;
      
    end
    
    function obj = updateIPUafter(obj,IPUobj,compareLength)
      % Adds start index, end index and duration of an IPU proceeding a 
      % turn. Checks whether the number of IPUs after an event (either
      % gap or overlap) is equal to the number of events. If not, the last
      % stored IPU is added to the IPUafter array for that event.
      if compareLength ~= obj.numData
        obj.numData = obj.numData + 1;
        obj.startIdx(obj.numData) = IPUobj.startIdx(IPUobj.numData);
        obj.endIdx(obj.numData)   = IPUobj.endIdx(IPUobj.numData);
        obj.duration(obj.numData) = IPUobj.duration(IPUobj.numData);
      end
    end

  end
  
end

