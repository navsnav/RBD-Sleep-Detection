function [riseSlope,fallSlope] = slopeHelper(sig,peakLoc,peak,prom,range)
%Provide slope information for peaks
% Input:
%       sig: input signal
%       peakLoc: index of peak value
%       peak: peak value
%       prom: peak prominence 
%       range: range around peak location
% Output:
%       riseSlope: slope value on rise to peak             
%       fallSlope: slope value on fall from peak 
%
% References:
%Yetton BD, Niknazar M, Duggan KA, McDevitt EA, Whitehurst LN, Sattari N, et al.
%Automatic detection of rapid eye movements (REMs): A machine learning approach. J Neurosci Methods. 2016;259:72–82. 


firstHalf = sig(1:peakLoc);
    logicalsInRangeFirstHalf = (firstHalf>(peak-prom*range(1))) & (firstHalf<(peak-prom*(1-range(2))));
    logicalsInRangeFirstHalf(1) = 0; %hack to force diff at start
    logicalsInRangeFirstHalf(end) = 0;
    indexsInRangeFirstHalf = find(diff(logicalsInRangeFirstHalf));
    if length(indexsInRangeFirstHalf) < 2
        riseSlope = 0;
    else
        rise = firstHalf(indexsInRangeFirstHalf(end))-firstHalf(indexsInRangeFirstHalf(end-1));
        run = indexsInRangeFirstHalf(end)-indexsInRangeFirstHalf(end-1);
        riseSlope = rise/run;
    end
    
    endHalf = sig(peakLoc+1:end);
    logicalsInRangeEndHalf = (endHalf>(peak-prom*range(1))) & (endHalf<(peak-prom*(1-range(2))));
    logicalsInRangeEndHalf(1)=0;%hack to force diff at start
    logicalsInRangeEndHalf(end)=0;%hack to force diff at end
    indexsInRangeEndHalf = find(diff(logicalsInRangeEndHalf));
    if length(indexsInRangeEndHalf) < 2
        fallSlope = 0;
    else
        rise = endHalf(indexsInRangeEndHalf(1))-endHalf(indexsInRangeEndHalf(2));
        run = indexsInRangeEndHalf(1)-indexsInRangeEndHalf(2);
        fallSlope = rise/run;
    end
%     plot(1:length(sig),sig,...
%        [indexsInRangeFirstHalf(end) indexsInRangeFirstHalf(end-1)],[firstHalf(indexsInRangeFirstHalf(end)) firstHalf(indexsInRangeFirstHalf(end-1))],...
%        [indexsInRangeEndHalf(1) indexsInRangeEndHalf(2)]+peakLoc,[endHalf(indexsInRangeEndHalf(1)) endHalf(indexsInRangeEndHalf(2))])
end