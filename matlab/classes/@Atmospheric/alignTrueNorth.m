function alignTrueNorth(this)
%ALIGNTRUENORTH Aligns lambertian conformal U and V to true north.
%
% SYNTAX:
%   this.alignTrueNorth();
% 
% DESCRIPTION:
%   Converts U and V wind components aligned to the RUC grid 
%   to U and V wind with respect to true north (meteorological standard).
%
% INPUTS:
%   this - Atmospheric object
%
% OUTPUTS: 
%   this - Atmospheric object, with winds updated in place.
%
% NOTES:
%   Verification:
%     Verified that rotation is zero at a longitude of -95 deg and 
%     increases as one goes away from -95 deg.  Verified that the wind 
%     speed never changes (just direction).  Also verified that the 
%     rotation was in the correct direction (clockwise).
%
%   References:
%     The math needed to perform this rotaion can be found at 
%     http://maps.fsl.noaa.gov/RUC.faq.html in the form of a snippit
%     of Fortran code provided by FSL.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

if this.windsAlignedToTrueNorth
  error('Winds already aligned to true north.')    
end

uName = ['uComponentOfWind' this.verticalCoordSys];
vName = ['vComponentOfWind' this.verticalCoordSys];

% Check that object has the right fields loaded.
if isprop(this,'longitude') && ...
    isprop(this,uName) &&...
    isprop(this,vName) && ...
    ~isempty(this.projection) && ...
    strcmp(this.projection.getClassName,'LambertConformal')

  u = this.(uName);
  v = this.(vName);

  % Retrieve projection parameters.
  originLat = this.projection.getOriginLat;
  rotConstant = sind(originLat);  
  meridianAlignment = this.projection.getOriginLon - 360;
  nLevels = size(u,1);

  % Vectorized, Calculate rotation conversions.
  angle = rotConstant.*(this.longitude - meridianAlignment); 
  cosAng = cosd(angle);
  sinAng = sind(angle);
  cosAng = shiftdim(repmat(cosAng,[1 1 nLevels]),2);
  sinAng = shiftdim(repmat(sinAng,[1 1 nLevels]),2);

  % Vectorized, Calculate wind vectors rotated wrt true North (met std).
  this.(uName) = (cosAng.* u) + (sinAng .* v); 
  this.(vName) = -(sinAng .* u) + (cosAng .* v);  
  
  this.windsAlignedToTrueNorth = true;
end
 