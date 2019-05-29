% Taken from FOC - graphical user interface to enter Zernike coefficients
% Original Author: Larry Thibos, University of Indiana

% First image in the array will be display by default at startup.

%logMAR = 0.3;                   % 0.3 logMAR = 0.5 AV, 0.1 logMAR = 0.9 AV
%AVd = 10^(-logMAR);             % [arcmin]
AVd = 0.1;
MAR = 1/AVd;


imgs = {    'hand.png',         0.2; % MAR * 1/24;   % one minute of arc for 24 pixels is AV 1.0
            'cookie.jpg',       1;
            'USAF3x.tif',       0.5;
            'target.bmp',       MAR * 1/17;   % the gap between the bars of the letter E is 17px high
            'eyechart2.hdf',    0.4;
            'moon.hdf',         1/6;
            'starpattern.hdf',  1/4;
            'zebra.hdf',        0.4;
            'TestChartA.hdf',   25.35/60;
            'TestChartB.hdf',   12.54/60;
            'Campbell.hdf',     0.4;
            'Cruise.tif',       1/5;
            'tumblingE chart 512x512.tif', 1/3;
            'Lena_bw.jpg',       1/5;
            'warrior.tif',       1/5 };

% example
% pixsize = 0.4 arcmin; size = 231x230 pix, = 1.5deg = 90arcmin
% FWC's head height is half the image = 0.75 deg = 45 arcmin = 13 mrad
% if head is 20 cm tall, then view distance must be 15 meters
% pixsize = 1.5 to make viewing distance = 4m.

% hand.png - one ball is 70 pixels high. ball's diameter is about 25mm
% from 6 meters it subtends tan(0.025/6)*180/pi = 0.24 deg = 14.3 arcmin
% from 3 meters, multiply by 2