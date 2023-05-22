function [i, nextCH, leaveSet] = determineStartCH(CHarray, leaveSet)
%% DETERMINESTARTCH
% Determine the channel(s) who has/have the first activity.
%
% Author: © Anna Josefine Munch Sørensen, annajosefine@gmail.com
% v. 1.0, January 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CHarray = bi2de(CHarray); 

for i = 2 : size(CHarray,1)
  if CHarray(i - 1) ~= CHarray(i) 
    state = CHarray(i-1);
    leaveSet(state+1) = i;
    nextCH = find(de2bi(CHarray(i),4));
    return
  end
end

