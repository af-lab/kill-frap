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

## Do not use this code for anything other than producing the figures for
## the thesis. The core of this script can be found at:
## https://github.com/af-lab/scripts/blob/master/microscopy/CropReg.m

montage_size = [5 4];

pkg load image;

if (numel (argv ()) < 1)
  printf ("No argument for image files")
  exit (1);
endif
fpath = argv (){1};

img = imread (dv2tif (fpath), "Index", "all");

## the image has been deconvolved so we need to trim the borders
img = img(31:end-30,31:end-30,:,:);

## although file bitdepth is 16bit, DeltaVision was actually only 12bit
## so this needs to be readjusted
img *= 2^(16-12);

red   = img(:,:,:,1:(size (img, 4) /2));        # mCherry alpha-tubulin
green = img(:,:,:,((size (img, 4) /2) +1):end); # H2B PAGFP
rgb   = cat (3, red, green, zeros (size (red), class (red)));

## we want to adjust the intensity based on the second frame, after
## the PAGFP has been activated. And we adjust the intensity of each
## channel separately.
function adjusted = adjust_j (img, f)
  imgd = im2double (img);
  mind = min (imgd(:,:,:,2)(:));
  maxd = max (imgd(:,:,:,2)(:)) / f;
  adjusted = im2uint16 ((imgd - mind) / maxd);
endfunction

## just the first two frames to show photo activation
prepost = rgb(300:end,250:end,:,1:2);
prepost(:,:,1,:) = adjust_j (prepost(:,:,1,:), 1); # adjust red channel
prepost(:,:,2,:) = adjust_j (prepost(:,:,2,:), 1); # adjust green channel
imwrite (prepost(:,:,:,1), "ifrap-pre.png");
imwrite (prepost(:,:,:,2), "ifrap-post.png");

## an even smaller crop of the bleach spot only
spot = imcrop (rgb, [275 420 250 150]);
spot(:,:,1,:) = adjust_j (spot(:,:,1,:), 0.3); # adjust red channel
spot(:,:,2,:) = adjust_j (spot(:,:,2,:), 1);   # adjust green channel

mont_img = montage_cdata (spot,
  "Size", montage_size,
  "Indices", 2:2:(prod (montage_size) *2 +1),
  "MarginWidth", 5
);
imwrite (mont_img, "ifrap.png");
