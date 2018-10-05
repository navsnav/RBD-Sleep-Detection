function [peakOne,peakTwo] = feature_amplitude2peak(sig)
% Provides details on local peaks found within sig (negative and positive)
% Input:
%       sig: input signal
% Output:
%       peakOne: Largest peak (positive or negative)              
%       peakOne: 2nd Largest peak (positive or negative)  
%

% References:
%Yetton BD, Niknazar M, Duggan KA, McDevitt EA, Whitehurst LN, Sattari N, et al.
%Automatic detection of rapid eye movements (REMs): A machine learning approach. J Neurosci Methods. 2016;259:72–82. 

%finds the min and max peaks above thresh
    [peaksMax,peaksMaxLoc,widthMax,promMax] = findpeaks(sig);
    [peaksMin,peaksMinLoc,widthMin,promMin] = findpeaks(-sig);

    [peakMin,locMin] = max(peaksMin);
    [peakMax,locMax] = max(peaksMax);
    peakMaxLoc = peaksMaxLoc(locMax);
    peakMinLoc = peaksMinLoc(locMin);
    
    if isempty(peakMax)
        peakMax = 0; %if there were no peaks in the data then compare to zero.
    end
    
    if isempty(peakMin)
        peakMin = 0;
    end
    
    if abs(peakMax) > abs(peakMin) %large peak
        peakOne.isPeakNeg = false;
        peakOne.peak = peakMax;
        peakOne.width = widthMax(locMax);
        peakOne.prom = promMax(locMax);
        peakOne.loc = locMax;
        [peakOne.riseSlope,peakOne.fallSlope] = slopeHelper(sig,peakMaxLoc,peakOne.peak,peakOne.prom,[0.5 1]);
    elseif abs(peakMax) < abs(peakMin) %large trough
        peakOne.isPeakNeg = true;
        peakOne.peak = peakMin;
        peakOne.width = widthMin(locMin);
        peakOne.prom = promMin(locMin);
        peakOne.loc = locMin;
        [peakOne.riseSlope,peakOne.fallSlope] = slopeHelper(-sig,peakMinLoc,peakOne.peak,peakOne.prom,[0.5 1]);
    else
        peakOne.isPeakNeg = false;
        peakOne.peak=0;
        peakOne.loc = nan;
        peakOne.width=0;
        peakOne.prom =0;
        peakOne.riseSlope =0;
        peakOne.fallSlope =0;
    end
        
    peaksMin(locMin) = -100; %set at some large negative value, so we dont pick it up again
    peaksMax(locMax) = -100;
    [peakMin,locMin] = max(peaksMin);
    [peakMax,locMax] = max(peaksMax);
    peakMaxLoc = peaksMaxLoc(locMax);
    peakMinLoc = peaksMinLoc(locMin);
    
    if isempty(peakMax)
        peakMax = 0; %if there were no peaks in the data then compare to zero.
    end
    
    if isempty(peakMin)
        peakMin = 0;
    end

    
    if abs(peakMax) > abs(peakMin) %large peak
        peakTwo.isPeakNeg = false;
        peakTwo.peak = peakMax;
        peakTwo.width = widthMax(locMax);
        peakTwo.prom = promMax(locMax);
        peakTwo.loc = locMax;
        [peakTwo.riseSlope,peakTwo.fallSlope] = slopeHelper(sig,peakMaxLoc,peakTwo.peak,peakTwo.prom,[0.5 1]);
    elseif abs(peakMax) < abs(peakMin) %large trough
        peakTwo.isPeakNeg = true;
        peakTwo.peak = peakMin;
        peakTwo.width = widthMin(locMin);
        peakTwo.prom = promMin(locMin);
        peakTwo.loc = locMin;
        [peakTwo.riseSlope,peakTwo.fallSlope] = slopeHelper(-sig,peakMinLoc,peakTwo.peak,peakTwo.prom,[0.5 1]);
    else
        peakTwo.isPeakNeg = false;
        peakTwo.peak=0;
        peakTwo.width=0;
        peakTwo.prom =0;
        peakTwo.riseSlope =0;
        peakTwo.fallSlope =0;
        peakTwo.loc = nan;
    end
end