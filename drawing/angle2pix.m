function pix = angle2pix(ang, dist, width, hres)
%pix = angle2pix(ang, dist, width, resolution)
%
%converts visual angles in degrees to pixels.
%
%Inputs:
%dist (distance from screen (cm))
%width (width of screen (cm))
%hres (number of pixels of display in horizontal direction)
%
%ang (visual angle)
%
%Warning: assumes isotropic (square) pixels

%Written 11/1/07 gmb zre

%Calculate pixel size
pixSize = width/hres;   %cm/pix

sz = 2*dist*tan(pi*ang/(2*180));  %cm

pix = round(sz/pixSize);   %pix 


return

%test code
