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
pkg load bioformats;
javaMethod ('enableLogging', 'loci.common.DebugTools', 'ERROR');

yx_pixel_size = [0.1041281]; #micron
yx_scalebar = [0.5 5]; # height and width in microns

if (numel (argv ()) != 2)
  error ("Requires exactly 2 arguments")
endif

fpath = argv (){1};
f_out = argv (){2};

montage_size = [3 4]; # total of 12 panels (3 rows by 4 columns)

pixel_region = {600, 250, 200, 200}; # x_init, y_init, width, height

reader = bfGetReader (fpath);
n_planes = reader.getImageCount ();
if (n_planes != 256)
  error ("we were expecting an image with 256 time points");
endif
planes_idx = [15 16 31 51 71 91 111 131 151 171 191 211];

img = bfGetPlane (reader, planes_idx(1), pixel_region{:});
img = postpad (img, numel (planes_idx), 0, 4);
for idx = 2:numel(planes_idx)
  img(:,:,:,idx) = bfGetPlane (reader, planes_idx(idx), pixel_region{:});
endfor

## Scale to the min and max of the whole scale for display.
img = imadjust (img, stretchlim (img(:), 0));

## Add a scalebar only to the pre bleach frames, top left corner.
bar_length = round (yx_scalebar ./ yx_pixel_size); # in pixels
bar_color = getrangefromclass (img)(2);
img(15:15+bar_length(1), 15:15+bar_length(2), :, 1) = bar_color;

mont_img = montage_cdata (img,
  "Size", montage_size
);

imwrite (mont_img, f_out);
