function SyntWF = WF_Model(N,Dataset,HOA, Figure)

% Generates any number of wavefront sets based on eigenvector decomposition
% with the same statistical and epidemiological properties as the original data
% Series based on 11th order Zernike series follwing OSA standard over a 5 mm pupil
%
% Input:  N                 - Number of SyntEyes to be generated
%         Dataset ('N'/'K') - Select Normal eyes ('N') or keratoconic eyes ('K')
%         HOA (0/1)         - Generate only higher order aberrations yes (1) or no (0)
%         Figure (0/1)      - Show result in a figure
%
% Output: SyntWF            - Struct with synthetic wavefronts in the form of normalized Zernike coefficents
%
% 
%
% 05/07/2016 V 1.1  - Jos J. Rozema

clc

if nargin == 0
    N       = 1000;
    Dataset = 'K';
    HOA     = 0;
    Figure  = 0;
elseif nargin == 1
    Dataset = 'K';
    HOA     = 0;
    Figure  = 0;
elseif nargin == 2
    HOA     = 0;
    Figure  = 0;
elseif nargin == 3
    Figure  = 0;
elseif nargin == 4
else
    error('Too many input parameters');
end


%%%%%%%%%%%%%%%%%%%%%
%% Read model data %%
%%%%%%%%%%%%%%%%%%%%%

%ModelData = open(['.',filesep,'includes',filesep,'eye_models',filesep,'WF_Model_Data.mat']);

load('WF_Model_Data.mat', 'WF_Normal_Total', 'WF_Normal_HOA', 'WF_KTC_Total', 'WF_KTC_HOA');

if and(Dataset == 'N',~HOA)
    Model = WF_Normal_Total;
elseif and(Dataset == 'N', HOA)
    Model = WF_Normal_HOA;
elseif and(Dataset == 'K',~HOA)
    Model = WF_KTC_Total;
elseif and(Dataset == 'K', HOA)
    Model = WF_KTC_HOA;
else
    error('Invalid input values');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fit Gaussian mixture distribution and generate random data accordingly %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S       = gmdistribution(Model.Fit.mu,Model.Sigma,Model.Fit.PComponents);   % Combine all components into a GM distribution
SyntWF  = random(S,N);                                                      % Generate random data according to GM distribution
SyntWF  = SyntWF*Model.EVconv';                                             % Convert eigencorneas back to corneal Zernikes and pachy

for k = 1:Model.Nzern
    SyntWF(:,k) = SyntWF(:,k) + Model.ZCavg(k);                             % Add the average Zernike coeff values (eigenvectors require zero mean)   
end

if HOA
    SyntWF  = [zeros(N,6) SyntWF];                                          % Add zeros for zeroth to second order Zernikes
else
    SyntWF  = [zeros(N,3) SyntWF];                                          % Add zeros for zeroth and first order Zernikes                                
end


%%%%%%%%%%%%%%%%%
%% Show figure %%
%%%%%%%%%%%%%%%%%

if Figure
    figure(1), bar(0:27,mean(SyntWF(:,1:28),1)); xlim([0 27]), xlabel('Zernike coefficient'), ylabel('Mean coefficient value (um)')
end

end