#!/usr/local/bin/octave -qf
##
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

montage_size = [6 5];

pkg load image;

if (numel (argv ()) < 1)
  printf ("No argument for image files")
  exit (1);
endif
fpath = argv (){1};

img = imread (dv2tif (fpath), "Index", "all");

## the image has been deconvolved so we need to trim the borders
img = img(31:end-30,31:end-30,:,:);

## the image is mostly black, this is the only cell, so we crop it
img = imcrop (img, [110 1 400 550]);

## although file bitdepth is 16bit, DeltaVision was actually only 12bit
## so this needs to be readjusted
img *= 2^(16-12);

mont_img = montage_cdata (img,
  "Size", montage_size,
  "MarginWidth", 10,
  "Indices", 1:(montage_size(1)*montage_size(2))
);
imwrite (mont_img, "confluent-horse.png")

