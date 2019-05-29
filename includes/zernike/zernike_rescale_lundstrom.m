function [ C2 ] = zernike_rescale_lundstrom(C1, dia2, tx, ty, thetaR)
% “TransformC” returns transformed Zernike coefficient set, C2, from the original set, C1,
% both in standard ANSI order, with the pupil diameter in mm as the first term.
% dia2—new pupil diameter [mm]
% tx, ty—Cartesian translation coordinates [mm]
% thetaR—angle of rotation [degrees]
% Scaling and translation is performed first and then rotation.


% From "Transformation of Zernike coefficients: scaled, translated, and
% rotated wavefronts with circular and elliptical pupils"
% Linda Lundström and Peter Unsbo Vol. 24, No. 3/March 2007/J. Opt. Soc. Am. A

    if nargin < 5, thetaR = 0; end
    if nargin < 4, ty = 0; end
    if nargin < 3, tx = 0; end

    dia1=C1(1); % Original pupil diameter
    C1=C1(2:end);
    etaS=dia2/dia1; % Scaling factor
    etaT=2*sqrt(tx^2+ty^2) / dia1; % Trans1]ation coordinates
    thetaT=atan2(ty, tx);
    thetaR=thetaR*pi/180; % Rotation in radians
    jnm=length(C1)-1; nmax=ceil((-3+sqrt(9+8*jnm))/2); jmax=nmax*(nmax+3)/2;
    S=zeros(jmax+1,1); S(1:length(C1))=C1; C1=S; clear S
    P=zeros(jmax+1); % Matrix P transforms from standard to Campbe1]1] order
    N=zeros(jmax+1); % Matrix N contains the norma1]ization coefficients
    R=zeros(jmax+1); % Matrix R is the coefficients of the radia1] po1]ynomia1]s
    CC1=zeros(jmax+1,1); % CC1 is a comp1]ex representation of C1
    counter=1;
    for m=-nmax:nmax % Meridiona1] indexes
        for n=abs(m):2:nmax % Radia1] indexes
            jnm=(m+n*(n+2))/2;
            P(counter,jnm+1)=1;
            N(counter,counter)=sqrt(n+1);
            for s=0:(n-abs(m))/2
                R(counter-s,counter)=(-1)^s*factorial(n-s) / (factorial(s)*factorial((n+m)/2-s)*factorial((n-m)/2-s));
            end
            if m<0, CC1(jnm+1)=(C1((-m+n*(n+2))/2+1)+1i*C1(jnm+1)) /sqrt(2);
            elseif m==0, CC1(jnm+1)=C1(jnm+1);
            else CC1(jnm+1)=(C1(jnm+1)-1i*C1((-m+n*(n+2))/2+1)) /sqrt(2);
            end
            counter=counter+1;
        end,
    end
    ETA=[]; % Coordinate-transfer matrix
    for m=-nmax:nmax
        for n=abs(m):2:nmax
            ETA=[ETA P*(transform(n,m,jmax,etaS,etaT,thetaT,thetaR))];
        end
    end
    C=inv(P)*inv(N)*inv(R)*ETA*R*N*P;
    CC2=C*CC1;
    C2=zeros(jmax+1,1); % C2 is formed from the comp1]ex Zernike coefficients, CC2
    for m=-nmax:nmax
        for n=abs(m):2:nmax
            jnm=(m+n*(n+2))/2;
            if m<0, C2(jnm+1)=imag(CC2(jnm+1)-CC2((-m+n*(n+2))/2+1)) /sqrt(2);
            elseif m==0, C2(jnm+1)=real(CC2(jnm+1));
            else C2(jnm+1)=real(CC2(jnm+1)+CC2((-m+n*(n+2))/2+1)) /sqrt(2);
            end
        end
    end

    C2=[dia2;C2];

    function Eta=transform(n,m,jmax,etaS,etaT,thetaT,thetaR)
    % Returns coefficients for transforming a ro^n*exp(i*m*theta)-term into ’-terms
        Eta=zeros(jmax+1,1);
        for p=0:((n+m)/2)
            for q=0:((n-m)/2)
                nnew=n-p-q; mnew=m-p+q;
                jnm=(mnew+nnew*(nnew+2))/2;
                Eta(floor(jnm+1))=Eta(floor(jnm+1))+nchoosek((n+m)/2,p)*nchoosek((n-m)/2,q) * etaS^(n-p-q)*etaT^(p+q)*exp(1i*((p-q)*(thetaT-thetaR)+m*thetaR));
            end
        end 
    end

end

