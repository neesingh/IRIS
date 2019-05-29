function Dat = CataractModel_Final(N, LowAge, HighAge)
% Modeling of effect of gradual lens opacification on straylight using the Villa Maria data
% USES LOCS II and cataract prevalence fits based on 6 points
% Extrapolated towards young eyes

    %###################
    %# Initialization ##
    %###################

    if(nargin < 1), N = 2500; end                       % Number of virtual subjects
    if(nargin < 2), LowAge  = 20; end                   % Lowest age of age interval
    if(nargin < 3), HighAge = 70; end                   % Highest age of age interval

    M = [1.000  0.450  0.800;                           % Correlation between lens opacity types (fine-tuned to match the real correlations between
         0.450  1.000  0.850;                           %	lens opacity scores as well as possible; seems to overestimate corr between Nuc and Cort)
         0.800  0.850  1.000;];


    %##########################################
    %# Estimate degree of lens opacification ##
    %##########################################

    Age     = (HighAge-LowAge)*rand(N,1) + LowAge;      % Random age data, between HighAge and LowAge
    LOpData = 100*MultivatiateUniformDistribution(N,M); % Random lens opacification data for Nuclear, Cortical and Posterior Subcapsular cataracts respectively


    %#####################
    %# Nuclear cataract ##
    %#####################

    NGr(:,3) =            0.0130*Age.^2 - 1.2025*Age + 28.184; Temp = Age < 55; NGr(Temp,3) = 0;
    NGr(:,2) = NGr(:,3) + 0.0377*Age.^2 - 3.1245*Age + 63.941; Temp = Age < 55; NGr(Temp,2) = 0;
    NGr(:,1) = NGr(:,2) - 0.1192*Age.^2 + 15.418*Age - 442.75; Temp = Age < 42; NGr(Temp,1) = 0;

    Nuc = zeros(N,1);

    Temp = LOpData(:,1) >   NGr(:,1);   Nuc(Temp) = -(LOpData(Temp,1)-NGr(Temp,1))./(100-NGr(Temp,1))         + 1;
    Temp = LOpData(:,1) <=  NGr(:,1);   Nuc(Temp) = -(LOpData(Temp,1)-NGr(Temp,2))./(NGr(Temp,1)-NGr(Temp,2)) + 2;
    Temp = LOpData(:,1) <=  NGr(:,2);   Nuc(Temp) = -(LOpData(Temp,1)-NGr(Temp,3))./(NGr(Temp,2)-NGr(Temp,3)) + 3;
    Temp = LOpData(:,1) <=  NGr(:,3);   Nuc(Temp) = -(LOpData(Temp,1)-0          )./(NGr(Temp,3)            ) + 4;



    %######################
    %# Cortical cataract ##
    %######################

    CGr(:,4) =            0.0202*Age.^2 - 2.0499*Age + 52.047; Temp = Age < 53; CGr(Temp,5) = 0;
    CGr(:,3) = CGr(:,4) + 0.0130*Age.^2 - 1.0109*Age + 18.420; Temp = Age < 50; CGr(Temp,4) = 0;
    CGr(:,2) = CGr(:,3) +                 0.3736*Age - 16.700; Temp = Age < 45; CGr(Temp,3) = 0;
    CGr(:,1) = CGr(:,2) - 0.0426*Age.^2 + 5.7733*Age - 165.15; Temp = Age < 40; CGr(Temp,2) = 0;

    Cor = zeros(N,1);

    Temp = LOpData(:,2) >   CGr(:,1);   Cor(Temp) = -(LOpData(Temp,2)-CGr(Temp,1))./(100-CGr(Temp,1))         + 1;
    Temp = LOpData(:,2) <=  CGr(:,1);   Cor(Temp) = -(LOpData(Temp,2)-CGr(Temp,2))./(CGr(Temp,1)-CGr(Temp,2)) + 2;
    Temp = LOpData(:,2) <=  CGr(:,2);   Cor(Temp) = -(LOpData(Temp,2)-CGr(Temp,3))./(CGr(Temp,2)-CGr(Temp,3)) + 3;
    Temp = LOpData(:,2) <=  CGr(:,3);   Cor(Temp) = -(LOpData(Temp,2)-CGr(Temp,4))./(CGr(Temp,3)-CGr(Temp,4)) + 4;
    Temp = LOpData(:,2) <=  CGr(:,4);   Cor(Temp) = -(LOpData(Temp,2)-          0)./(CGr(Temp,4)-          0) + 5;


    %###################################
    %# Posterior subcapsular cataract ##
    %###################################

    PGr(:,3) =            0.0085*Age.^2 - 0.8994*Age - 23.541; Temp = Age < 59; PGr(Temp,3) = 0;
    PGr(:,2) = PGr(:,3) + 0.0086*Age.^2 - 0.5749*Age + 7.4866; Temp = Age < 50; PGr(Temp,2) = 0;
    PGr(:,1) = PGr(:,2) - 0.0212*Age.^2 + 3.2395*Age - 98.623; Temp = Age < 41; PGr(Temp,1) = 0;

    PSC = zeros(N,1);

    Temp = LOpData(:,3) >   PGr(:,1);   PSC(Temp) = -(LOpData(Temp,3)-PGr(Temp,1))./(100-PGr(Temp,1))         + 1;
    Temp = LOpData(:,3) <=  PGr(:,1);   PSC(Temp) = -(LOpData(Temp,3)-PGr(Temp,2))./(PGr(Temp,1)-PGr(Temp,2)) + 2;
    Temp = LOpData(:,3) <=  PGr(:,2);   PSC(Temp) = -(LOpData(Temp,3)-PGr(Temp,3))./(PGr(Temp,2)-PGr(Temp,3)) + 3;
    Temp = LOpData(:,3) <=  PGr(:,3);   PSC(Temp) = -(LOpData(Temp,3)-          0)./(PGr(Temp,3)-          0) + 4;


    %####################################
    %# Estimate and display straylight ##
    %####################################

    SL = 0.962 + 0.216*(Nuc-0.5) + 0.036*(Cor-0.5) + 0.141*(PSC-0.5); % LOCS II linear regression incl young eyes
    SL = SL + 0.0042*(Age >= 40).*(Age-40)-0.02;

    figure, set(gcf,'Color',[1 1 1])
        scatter(Age,SL-0,'b.'), hold on
        Age2 = LowAge:1:HighAge;
        plot(Age2, 0.931 + log10(1+(Age2/65).^4),'r', 'LineWidth',3)
        plot(Age2, 0.931 + log10(1+(Age2/65).^4)-0.2,'--r', 'LineWidth',2)
        plot(Age2, 0.931 + log10(1+(Age2/65).^4)+0.2,'--r', 'LineWidth',2)
        xlabel('Subject age (years)')
        ylabel('log(s)')
        legend('Model data','van den Berg model','Location','NorthWest')
        box on
        hold off
        ylim([0.7 2.2])

    Dat = [Age Nuc Cor PSC SL];
end

function Y = MultivatiateUniformDistribution(N,M)
    % Taken from http://comisef.wikidot.com/tutorial:correlateduniformvariates

    % generate normals, check correlations
    X = randn(N,3);

    % adjust correlations for uniforms
    for i = 1:3
        for j = 1:3
            if i ~= j
                M(i, j) = 2 * sin(pi * M(i, j) / 6);
                M(j, i) = 2 * sin(pi * M(j, i) / 6);
            end
        end
    end

    C = chol(M);                                    % induce correlation
    Y = X * C;
    Y(:,1:3) = normcdf(Y(:,1:3));                   % create uniforms

    % plot results (marginals)
    % for i=1:3
    %     subplot(2,2,i);
    %     hist(Y(:,i))
    %     title(['Y ', int2str(i)])
    % end

end
