function [ zernikes ] = zernike_rescale_schwiegerling( sz, x )
% [ zernikes ] = zernike_rescale( sz, x )
%
% sz [um] - source zernike
% x [1] - ratio between target pupil radius and original pupil radius
%
% This code is from Jim Schwiegerling ncalculated per Table 1 of the publication:
% Schwiegerling, J. (2002). Scaling Zernike expansion coefficients to
% different pupil sizes. J Opt Soc Am A, 19 (10), 1937-1945.

% Adapted by: M. Jaskulski, Universidad de Murcia, mateusz.jaskulski@gmail.com.

    modes = length(sz);
    
    % elegant way to make sure there are 36
    sz = [sz, zeros(1, max(0, 36 - modes))];
    sz = sz(1:36);

    zernikes(1)=sz(1)-sz(5)*sqrt(3.0)*(1.0-x^2)+sz(13)*sqrt(5.0)*(1.0-3.0*x^2+2.0*x^4)-sz(25)*sqrt(7.0)*(1.0-6.0*x^2+10.0*x^4-5.0*x^6);
    zernikes(2)=x*(sz(2)-sz(8)*sqrt(8.0)*(1-x^2)+sz(18)*sqrt(3.0)*(3.0-8.0*x^2+5.0*x^4)-sz(32)*4.0*(2.0-14.0*x^2+5.0*x^4+7.0*x^6));
    zernikes(3)=x*(sz(3)-sz(9)*sqrt(8.0)*(1-x^2)+sz(19)*sqrt(3.0)*(3.0-8.0*x^2+5.0*x^4)-sz(33)*4.0*(2.0-14.0*x^2+5.0*x^4+7.0*x^6));

    zernikes(4)=x^2*(sz(4)-sz(12)*sqrt(15.0)*(1.0-x^2)+sz(24)*sqrt(21.0)*(2.0-5.0*x^2+3.0*x^4));
    zernikes(5)=x^2*(sz(5)-sz(13)*sqrt(15.0)*(1.0-x^2)+sz(25)*sqrt(21.0)*(2.0-5.0*x^2+3.0*x^4));
    zernikes(6)=x^2*(sz(6)-sz(14)*sqrt(15.0)*(1.0-x^2)+sz(26)*sqrt(21.0)*(2.0-5.0*x^2+3.0*x^4));

    zernikes(7)=x^3*(sz(7)-sz(17)*2*sqrt(6.0)*(1.0-x^2)+sz(31)*2.0*sqrt(2.0)*(5.0-12.0*x^2+7.0*x^4));
    zernikes(8)=x^3*(sz(8)-sz(18)*2*sqrt(6.0)*(1.0-x^2)+sz(32)*2.0*sqrt(2.0)*(5.0-12.0*x^2+7.0*x^4));
    zernikes(9)=x^3*(sz(9)-sz(19)*2*sqrt(6.0)*(1.0-x^2)+sz(33)*2.0*sqrt(2.0)*(5.0-12.0*x^2+7.0*x^4));
    zernikes(10)=x^3*(sz(10)-sz(20)*2*sqrt(6.0)*(1.0-x^2)+sz(34)*2.0*sqrt(2.0)*(5.0-12.0*x^2+7.0*x^4));

    zernikes(11)=x^4*(sz(11)-sz(23)*sqrt(35.0)*(1-x^2));
    zernikes(12)=x^4*(sz(12)-sz(24)*sqrt(35.0)*(1-x^2));
    zernikes(13)=x^4*(sz(13)-sz(25)*sqrt(35.0)*(1-x^2));
    zernikes(14)=x^4*(sz(14)-sz(26)*sqrt(35.0)*(1-x^2));
    zernikes(15)=x^4*(sz(15)-sz(27)*sqrt(35.0)*(1-x^2));

    zernikes(16)=x^5*(sz(16)-sz(30)*4.0*sqrt(3.0)*(1.0-x^2));
    zernikes(17)=x^5*(sz(17)-sz(31)*4.0*sqrt(3.0)*(1.0-x^2));
    zernikes(18)=x^5*(sz(18)-sz(32)*4.0*sqrt(3.0)*(1.0-x^2));
    zernikes(19)=x^5*(sz(19)-sz(33)*4.0*sqrt(3.0)*(1.0-x^2));
    zernikes(20)=x^5*(sz(20)-sz(34)*4.0*sqrt(3.0)*(1.0-x^2));
    zernikes(21)=x^5*(sz(21)-sz(35)*4.0*sqrt(3.0)*(1.0-x^2));

    zernikes(22)=x^6*sz(22); %6,-6
    zernikes(23)=x^6*sz(23); %6,-4
    zernikes(24)=x^6*sz(24); %6,-2
    zernikes(25)=x^6*sz(25); %6,0
    zernikes(26)=x^6*sz(26); %6,2
    zernikes(27)=x^6*sz(27); %6,4
    zernikes(28)=x^6*sz(28); %6,6

    zernikes(29)=x^7*sz(29); %7-7
    zernikes(30)=x^7*sz(30); %7-5
    zernikes(31)=x^7*sz(31); %7-3
    zernikes(32)=x^7*sz(32); %7-1
    zernikes(33)=x^7*sz(33); %71
    zernikes(34)=x^7*sz(34); %73
    zernikes(35)=x^7*sz(35); %75
    zernikes(36)=x^7*sz(36); %77

    zernikes = zernikes(1:min(36, modes));  

end

