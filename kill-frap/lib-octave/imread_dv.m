## Copyright (C) 2014-2016 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## Original image is on the proprietary dv file format. We use the
## bioformats to read it.

function img = imread_dv (fpath)
  if (nargin < 1)
    print_usage ();
  endif

  pkg load bioformats;
  javaMethod ('enableLogging', 'loci.common.DebugTools', 'ERROR');

  reader = bfGetReader (fpath);
  n_planes = reader.getImageCount ();
  img = bfGetPlane (reader, 1);
  img = postpad (img, n_planes, 0, 4);
  for p_idx = 2:n_planes
    img(:,:,:,p_idx) = bfGetPlane (reader, p_idx);
  endfor
endfunction
