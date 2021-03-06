%% Description
% Polynomial fitting
% Unpublished results
%
%% Copyright 
% BSD 3-Clause License
% Copyright 2016-2017 G. Erny (guillaume@fe.up,pt), FEUP, Porto, Portugal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [z, bslPts] = doPF(XY, n)
% input: XY 2xn array,
%        n order iof the polynomial
% output:
%        z basline model
%        bslPts false if peak pts, true in baseline pts

N = length(XY(:,1));
w = ones(N, 1);
L = 0;
iterMax = 20;

for ii = 1:iterMax;
    
    p = polyfit(XY(w > 0.05,1), XY(w > 0.05,2), n);
    z = polyval(p, XY(:,1));
    d = XY(:,2) - z;
    
    dn = d(w > 0.05);
    % dn is the part of the data that are baseline points
    
    m = mean(dn);
    s = std(dn);
    w = 1./(1 + exp(2*(abs(d) - (2*s-m))/s));
    %%% ORIGINAL
    
    if length(dn) ==  L, break; end
    L = length(dn);
    % Check the baseline points and stop the loop if no more points are
    % detected as baseline
    
end

bslPts = abs((m-d)/s) < 1.98;
