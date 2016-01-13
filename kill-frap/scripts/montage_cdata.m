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

## because it's hard to get the actual image displayed withy montage()

function cdata = montage_cdata (varargin)
  h = figure ();
  set (h, "visible", "off");
  mh = montage (varargin{:});
  ## see bug #41240 (class is not preserved in cdata field)
  cdata = cast (get (mh, "cdata"), class (varargin{1}));
  close (h);
endfunction
