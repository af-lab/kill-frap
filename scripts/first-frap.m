#!/usr/bin/env octave
##
## Copyright (C) 2017 Carnë Draug <carandraug+dev@gmail.com>
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

pkg load image;

yx_pixelsize = [0.1074080]; # micron
yx_scalebar = [1 10]; # height and width in microns

n_prebleach = 20; # last frame before bleaching

if (numel (argv ()) != 7)
  error ("Requires exactly 7 arguments")
endif
in_fpath = argv (){1};
out_fpaths = argv ()(2:end);

img = imread_dv (in_fpath);

## We only care about the centre, where the cells are.
img = imcrop (img, [257 257 511 511]);

## Scale to the min and max of the whole scale for display.
img = imadjust (img, stretchlim (img(:), 0));

## Add a scalebar only to the pre bleach frames, top left corner.
bar_length = round (yx_scalebar ./ yx_pixelsize); # in pixels
bar_color = getrangefromclass (img)(2);
img(25:25+bar_length(1), 25:25+bar_length(2), :, 1:n_prebleach) = bar_color;

## We don't really need this but having this checks means if we change
## somewhere we will remember to fix the rest.
frames = [20 21 55 65 75 85];

for i = 1:numel(out_fpaths)
  fpath = out_fpaths{i};
  if (isempty (regexp (fpath, ["-" num2str(frames(i)) ".png"])))
    error ("unexpected frame");
  endif
  imwrite (img(:,:,:,frames(i)), fpath);
endfor
