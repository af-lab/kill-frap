#!/usr/local/bin/octave -qf
##
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

## Do not use this code for anything other than producing the figures for
## the thesis. The core of this script can be found at:
## https://github.com/af-lab/scripts/blob/master/microscopy/CropReg.m

pkg load image;

yx_pixelsize = [0.06644]; # micron
yx_scalebar = [1 10]; # height and width in microns
yx_scalebar_spot = [0.2 2]; # height and width in microns

montage_size = [5 4];

if (numel (argv ()) != 4)
  error ("Requires exactly 4 arguments")
endif

in_img    = argv (){1};
out_pre   = argv (){2};
out_post  = argv (){3};
out_iFRAP = argv (){4};

img = imread_dv (in_img);

## the image has been deconvolved so we need to trim the borders
img = img(31:end-30,31:end-30,:,:);

## although file bitdepth is 16bit, DeltaVision was actually only 12bit
## so this needs to be readjusted
img *= 2^(16-12);

red   = img(:,:,:,1:(size (img, 4) /2));        # mCherry alpha-tubulin
green = img(:,:,:,((size (img, 4) /2) +1):end); # H2B PAGFP
rgb   = cat (3, red, green, zeros (size (red), class (red)));


## Just the first two frames to show photo activation.  We will adjust
## intensity based on the second frame, after photo-activation.
prepost = rgb(300:end,250:end,:,1:2);
pre_lims = stretchlim (prepost(:,:,:,2), 0);
prepost = imadjust (prepost, repmat (pre_lims, [1 1 2]));

## Add a scalebar only the pre bleach frame, bottom right corner.
bar_length = round (yx_scalebar ./ yx_pixelsize); # in pixels
bar_color = getrangefromclass (prepost)(2);
prepost(600-bar_length(1):600, 650-bar_length(2):650, :, 1) = bar_color;

imwrite (prepost(:,:,:,1), out_pre);
imwrite (prepost(:,:,:,2), out_post);

## An even smaller crop of the bleach spot only
spot = imcrop (rgb, [275 420 250 150]);
spot_lims = stretchlim (spot(:,:,:,2), 0);
spot_lims(2,1,:) /= 0.3;
spot = imadjust (spot, repmat (spot_lims, [1 1 size(spot, 4)]));

## Add a smaller scalebar again on the recovery frames since they
## appear amplified in the manuscript, bottom left corner.
bar_length = round ((yx_scalebar_spot) ./ yx_pixelsize); # in pixels
bar_color = getrangefromclass (prepost)(2);
spot(145-bar_length(1):145, 25:25+bar_length(2), :, 1:2) = bar_color;

mont_img = montage_cdata (spot,
  "Size", montage_size,
  "Indices", 2:2:(prod (montage_size) *2 +1),
  "MarginWidth", 5
);
imwrite (mont_img, out_iFRAP);
