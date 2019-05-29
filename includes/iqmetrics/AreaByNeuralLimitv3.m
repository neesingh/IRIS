function [cutoff, area, CSF, sf] = AreaByNeuralLimitv3(rsf, rmtf, MTForOTF, showit)% AreaByNeuralLimitv3 - find cutoff spatial frequency and area under rMTF%% input: %	rsf = vector of radial spatial frequencies (cyc/deg) that supports rMTF%	rmtf = radial MTF (or rOTF) %	MTForOTF = flag to indicate whether rmtf is an MTF (flag=1) or an OTF (flag=0)%		If an OTF, then cutoff SF = first intersection with neural%		threshold%		If an MTF, then cutoff = last intersection  (cflag=1) of rmtf and neural threshold %	showit = 1 to display diagnostic graphics. default = 0%% outputs:%	cutoff = cutoff spatial frequency = intersection of neural contrast and rMTF%	area = area above neural threshold and below rMTF%   CSF  = predicted CSF%    sf = vector of support frequencies for CSF%% An example of defining cutoff SF as the intersection of MTF and neural threshold can be found%  in Thibos, JOSA-A 4:1673 (1987).  % Use of enveloped area goes back to Charman & Olin (1965).  See Ch 2 of Mouroulis for ref.% For case of radial MTF, count phase-reversed segments of the curve as positive area.%   Makes sense to define cutoff as the highest SF for which rMTF exceeds neural theshold.%   This permits spurious resolution to be counted as beneficial.% For case of radial OTF, then spatial phase errors lead to negative areas.%	Now it makes sense to define cutoff as the lowest SF for which rOTF is below neural threshold. %   This permits spurious resolution to be counted as deleterious.%% LNT 14-Nov-02. This is Version 3 of Xin Hong's program. Version3 is a %   simpler way to find cutoff SF.  Hopefully will be more robust than Xin's %	polynomial-fitting method. It wasn't clear how the polynomial method %	would deal with non-monotonic rMTFs that intersect threshold fn at%	several SFs.  Which root is found? % LNT 27Feb03. Set area=0 and cutoff=0 if cutoff = empty. Or, could set%   these to NaN if necessary.% LNT 30Jan05 - small mod to legend of diagnostic figure% � 2002, 2003, 2005 Larry Thibos, Indiana University% LNT 15-Oct-2010.  Add CSF calculation for Zeiss project% LNT 02-Aug-2012. Move CSF calculation forward in case of early exit.if nargin<4 || isempty(showit), showit=0; end;	% default is to not show the diagnostic display% showit=1; % diagnostic[p1,Spoly1,sf,CS,Thresh]=getNeuralCSF(rsf);index = 1:length(sf);					% limit input spatial frequencies to the range 0-60 cyc/deg			CSF =  rmtf(1:length(Thresh)) ./ Thresh;  % the predicted human contrast sensitivity functionif MTForOTF	cindex = max(find(rmtf(index) >= Thresh));	% index to highest SFs for which MTF > threshold    txt = 'rMTF';else	cindex = min(find(rmtf(index) <= Thresh));	% index to lowest SFs for which OTF < threshold    txt = 'rOTF';end	cutoff = rsf((cindex));					% cutoff SF if isempty(cutoff), area=0; cutoff=0; return, end	% early exit should never happenrindex = find(rsf < cutoff);			% index for those SFs between 0 and cutoff if length(rindex)<2, area=0; cutoff=0; return, end	% early exit area1 = trapz(sf(rindex),rmtf(rindex));	% area under rMTF curve for SF < cutoffarea2 = trapz(sf(rindex),Thresh(rindex)); % area under neural threshold curve for SF < cutoffarea = area1 - area2;					% area below rMTF and above neural threshold    if showit;	% diagnostic display indicates this fn. is behaving sensibly	figure; plot(sf,Thresh,'g-'); hold on;	plot(rsf,rmtf,'r-',cutoff,rmtf(cindex),'b*'); hold off;	legend('Neural threshold',txt,'cutoff')	t1=(['cutoff SF: ',num2str(cutoff)]); disp(t1)	t2=(['area of visibility: ',num2str(area)]); disp(t2)	title([t1,' ',t2])    figure; loglog(sf,CSF,'k'); xlabel('Spatial freq'); ylabel('Contrast sensitivity')    pause(3) % give user a chance to see what's happeningend% end of AreaByNeuralLimitv3.m