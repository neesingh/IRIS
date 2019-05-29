function ID = IQ2ID(IQ,method)
% convert IQ metrics produced by QualityMetrics.m into image degradation
% metrics (ID) that increase when the image gets worse.  This overcomes an
% inconvenient feature of IQ metrics: some get bigger and some get smaller
% as image quality increases.
% 
%  Syntax: ID = IQ2ID(IQ,method);
%
%  Input:  
%   IQ = a matrix of IQ values. Each col is a metric, each row an observation.
%   method = 1 or 2 (default = 2) as defined in metricNames.m
%     method 1 subtracts normalized metrics from 1. This method is not
%       intended for with un-normalized metrics.
%     method 2 inverts the metric and then takes the log to stretch it out
%       This approach worked well for Xu's data in Oct, 2006 (see PlotXu.m)
%       Method 2 makes sense for un-normalized IQ metrics as well.
%
%  Output:
%   ID = a matrix the same size as IQ
%
% LNT 7-May-08
% LNT 8-Oct-2010.  Trap & replace zeros with eps to avoid NaNs.

if nargin<2 || isempty(method), method = 2; end

ID = IQ;    % take a copy of input matrix

% Make a list of the metrics that increase when IQ increases
list1=[4:7,9,10]; % pupil fraction metrics
list2=[16:18,20:21,23,25:31]; % normalized IQ metrics
list3=[22,24];  % spatial frequency cutoffs

if method==1
    ID(:,list1) = 1-ID(:,list1); % fraction of pupil with poor IQ
    ID(:,list2) = 1-ID(:,list2); % 1 - normalized IQ
    ID(:,list3) = 1./ID(:,list3);    % cutoff period rather than spat. freq.
else   
    ID(ID==0)=eps;  % trap & replace zeros to avoid log problems
    ID(:,list1) = -log10(ID(:,list1)); % log(1/pupil fraction)
    ID(:,list2) = -log10(ID(:,list2)); % log(1/IQ)
    ID(:,list3)= 1./ID(:,list3);    % cutoff period rather than spat. freq.
end
ID = real(ID);  % delete nusiance imaginary components