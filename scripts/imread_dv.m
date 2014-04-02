## Copyright (C) 2014 Carnë Draug <carandraug+dev@gmail.com>
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
## bioformats command line tools to convert it to tif

function img = imread_dv (dv, varargin)
  if (nargin < 1)
    print_usage ();
  endif
  [fdir, fname, fext] = fileparts (dv);
  tif = fullfile (fdir, [fname ".tif"]);

  [status, output] = system (sprintf ("bfconvert -overwrite %s %s", dv, tif));
  if (status)
    error (output);
  endif
  img = imread (tif, varargin{:});

  [err, msg] = unlink (tif);
  if (err)
    warning ("imread_dv: unable to remove tif file after conversion from dv");
  endif
endfunction
