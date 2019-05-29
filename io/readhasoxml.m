function [ zc, pradius, pcenter ] = readhasoxml( xhaso )

% relevant labels and names to find the correct data
zernname       = 'TAB_Zernike (microns)';
pradiuscluster = 'ZER_ASPH_Parameters';
pradiusname    = 'Zernike pupil radius (mm)';
pcentername    = 'Zernike pupil center (mm)';
xname          = 'X';
yname          = 'Y';
namelabel      = 'Name';
arraylabel     = 'Array';
clusterlabel   = 'Cluster';
dimlabel       = 'Dimsize';
dbllabel       = 'DBL';
sgllabel       = 'SGL';
vallabel       = 'Val';

% get array containing the Zernike coefficients
zernarray = xhaso.getElementsByTagName( arraylabel );
for i = 0:( zernarray.getLength - 1 )
    if strcmp( zernarray.item(i).getElementsByTagName( namelabel ).item(0).getFirstChild.getData, zernname )
        zernarray = zernarray.item(i);
        break;
    end
end

% get number of Zernike coefficients
nzern = str2double( zernarray.getElementsByTagName( dimlabel ).item(0).getFirstChild.getData );

% select only the Zernike ...
zernarray = zernarray.getElementsByTagName( dbllabel );

% ... and extract one by one all of them
zc = zeros( nzern, 1 );
for i = 1:nzern
    zc(i) = str2double( zernarray.item(i-1).getElementsByTagName( vallabel ).item(0).getFirstChild.getData );
end

% get radius and center buried in the Cluster sections of the XML
xhasoclusters = xhaso.getElementsByTagName( clusterlabel );
for i = 0:( xhasoclusters.getLength - 1 )
    % get pupil radius
    if strcmp( xhasoclusters.item(i).getElementsByTagName( namelabel ).item(0).getFirstChild.getData, pradiuscluster )
        asph = xhasoclusters.item(i).getElementsByTagName( sgllabel );
        for j = 0:( asph.getLength - 1 )
            if strcmp( asph.item(j).getElementsByTagName( namelabel ).item(0).getFirstChild.getData, pradiusname )
                pradius = str2double( asph.item(j).getElementsByTagName( vallabel ).item(0).getFirstChild.getData );
                break;
            end
        end
    end
    % get pupil center
    if strcmp( xhasoclusters.item(i).getElementsByTagName( namelabel ).item(0).getFirstChild.getData, pcentername )
        xydata = xhasoclusters.item(i).getElementsByTagName( sgllabel );
        for j = 0:( xydata.getLength - 1 )
            if strcmp( xydata.item(j).getElementsByTagName( namelabel ).item(0).getFirstChild.getData, xname )
                pcenter(1,1) = str2double( xydata.item(j).getElementsByTagName( vallabel ).item(0).getFirstChild.getData );
            end
            if strcmp( xydata.item(j).getElementsByTagName( namelabel ).item(0).getFirstChild.getData, yname )
                pcenter(2,1) = str2double( xydata.item(j).getElementsByTagName( vallabel ).item(0).getFirstChild.getData );
            end
        end
    end
end