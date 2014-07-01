function [fg, kept] = feClipFibersToVolume(fg,coords,maxVolDist)
% Clip fibers to be constrained within a Volume.
%
%  function fibers = feClipFibersToVolume(fibers,coords,maxVolDist)
%
% INPUTS:
%        fibers         - A cell array of fibers, each defined as a 3xN array
%                         of x,y,z coordinates. E.g., fg.fibers.
%        coords         - A volume of defined as a 3xN array of x,y,z coordinates.
%        maxVolDist     - The farther distance (in mm) from the volume a node can
%                         be to be kept in the fiber.
%        
% OUTPUTS:
%        fibersOut      - A cell-array of fibers clipped within the volume 
%                        defined by coords.
%        kept           - fibers that were kept out of the original fiber
%                         group. Because fibers left with no nodes in coords
%                         are deleted the numbe rof kept fibes can be less
%                         then the original number of fibers,
%
% SEE ALSO: feClipFiberNodes.m, feConnectomePreprocess.m
% 
%
% Copyright (2013-2014), Franco Pestilli, Stanford University, pestillifranco@gmail.com.

% Handling parallel processing
poolwasopen = 1; % if a matlabpool was open already we do not open nor close one
if (matlabpool('size') == 0), matlabpool open; poolwasopen=0; end
fibers    = fg.fibers;

% Make sure the coordinates were passed with the expected dimesnions
if ~((size(coords,1) == 3) && (size(coords,2)>=3))
  coords = coords';
end

parfor ii = 1:length(fibers)
  % Compute the squared distance between each node on fiber ii and the
  % nearest roi coordinate
  [~, nodesSqDistance] = nearpoints(fibers{ii}, coords);
  
  % Keep the nodes in the fiber less than the wanted distance
  nodesToKeep = (sqrt(nodesSqDistance) <= maxVolDist);
  fibers{ii}  = fibers{ii}(:,nodesToKeep);
end
fg.fibers     = fibers; clear fibers;

% Remove the empty fibers, fibers that had no nodes in the volume
kept = (~cellfun('isempty',fg.fibers));
if sum(kept) < length(kept)
fg           = fgExtract(fg,kept,'keep');
end

if ~poolwasopen, matlabpool close; end

end % Main function
