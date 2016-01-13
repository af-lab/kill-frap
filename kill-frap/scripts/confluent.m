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

pkg load image;
addpath (fileparts (mfilename ("fullpath")));

if (numel (argv ()) != 2)
  error ("Requires exactly 2 arguments")
endif

fpath = argv (){1};
f_out = argv (){2};

montage_size = [6 4]; # total of 24 panels (6 rows by 4 columns)

## The following is if we wanted to load all frames, and have an
## equal interval ranging from the start to the end of the image.
##
## The image file 512MB, and even though the images are uint8, Magick++ will
## read it as uint16 or uint32, it it was build with that quantum-depth. That
## may cause out of memory errors, or just crash the whole system (specially
## if I'm booting from a USB stick).
##
#{
img     = imread (fpath, "Index", "all");
nFrames = size (img, 4); # will be 466

subs      = img - shift (img, -1, 4);
diffs     = sum (sum (subs));
[~, nPre] = max (diffs(:)); # will be 15

## calculate the index of the frames to use
nFRAP    = nFrames - nPre;
nPanels  = montage_size(1) * montage_size(2);
interval = ceil (nFRAP / (nPanels -1));     # -1 because the first panel will be for pre-bleach
indices  = [nPre nPre+1:interval:nFrames];

img = img(:,:,:,indices); # or we use the Indices option of montage()
#}

## However, we actually only want part of the whole field of view, one image
## for every 21 minutes, each frame has a 90 seconds interval, and the first
## 15 frames are pre-bleach. But we are readong from the lsm files so only
## each other frame counts
indices = [0:34:960](1:23);
indices = [29 indices+31];

img = imread (fpath,
  "Index", indices,
  "PixelRegion", {[429 842], [105 482]}
);

## I don't want to use the current version of imadjust because it needs 
## to be changed for Matlab incompatibilities. The following will at least
## keep stable
imgd = im2double (img);
mind = min (imgd(:,:,:,1)(:));
maxd = max (imgd(:,:,:,1)(:));
imgd = (imgd - mind) / maxd;
img  = im2uint8 (imgd);

mont_img = montage_cdata (img,
  "Size", montage_size,
  "MarginWidth", 10
);
imwrite (mont_img, f_out)

