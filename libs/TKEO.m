function [TKenergy]=TKEO(x)
%
%% Utility function to calculate measures based on the nonlinear energy operator
%
% Function to estimate the TKEO of input data, follows the classical rule
% of Teager and Kaiser
%
% Inputs:  x            -> any time-series signal (vector)
%
% =========================================================================
% Output:  TKenergy     -> (nonlinear) Teager-Kaiser Energy Operator (TKEO)
% =========================================================================
%
% Part of the "Speech Disorders" Toolbox
%
% -----------------------------------------------------------------------
% Useful references:
% 
% 1) J. Kaiser: On a simple algorithm to calculate the 'energy' of a
%    signal, Proc. IEEE International Conference on Acoustics, Speech, and 
%    Signal Processing (ICASSP '90), pp. 381-384, Albuquerque, NM, USA, 
%    April 1990
%
% -----------------------------------------------------------------------
%
% Last modified on 24 August 2014
%
% Copyright (c) Athanasios Tsanas, 2014
%
% ********************************************************************
% If you use this program please cite:
%
% 1) A. Tsanas: "Accurate telemonitoring of Parkinson's disease symptom
%    severity using nonlinear speech signal processing and statistical
%    machine learning", D.Phil. thesis, University of Oxford, 2012
% ********************************************************************
%
% For any question, to report bugs, or just to say this was useful, email
% tsanasthanasis@gmail.com

%% Algorithm computation

% The algorithm is computed using the instantaneous value squared minus the
% previous step value times the next step value:[x_n]^2-[x_(n-1)]*(x_(n+1)]

data_length=length(x);
TKenergy=zeros(data_length,1);

TKenergy(1)=(x(1))^2; % first sample

for n=2:data_length-1
    TKenergy(n)=(x(n))^2-x(n-1)*x(n+1);
end

%  TKenergy(2:data_length-1) = x(2:data_length-1).^2 - x(1:data_length-2).*x(3:data_length); % alternative, vectorized version

TKenergy(data_length)=(x(data_length))^2; % last sample
