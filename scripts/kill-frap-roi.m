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

## This is a piece of code adapted from the FRAPINATOR program, see
## https://github.com/af-lab/frapinator , only meant to generate
## the images for the thesis, since we want some additional formatting
## for style purposes only.

## While any file should work fine, the image we used for the thesis was
##
##        Location8Cell1
##
## from the dataset
##
##        2010-04-28 H4 R45H (11h after mitosis) 20px circle and 30ms scan and laser 7 2500frames
##
## This was one of the images collected at NIH in a Zeiss 510. Since we kept
## the original lsm files, I'll guess more details of the system can be found
## in the metadata of the file.

pkg load image;
addpath (fileparts (mfilename ("fullpath")));

if (numel (argv ()) != 5)
  error ("Requires exactly 5 arguments")
endif

fpath = argv (){1};
fpre  = argv (){2};
fpost = argv (){3};
fsub  = argv (){4};
fsel  = argv (){5};

## Even though the images are uint8, this may cause out of memory errors
## if GraphicsMagick was built with quantum-depth 32. Also, we read every
## other image because lsm files have the thumbnails intertwined
img = imread (fpath, "Index", 1:2:240);

function [perim] = find_background (img)
  ## we used a 30x30 square for background
  bkg_size = 30;

  ## Find minimum of the convolution matrix
  conv_matrix  = conv2 (img, ones (bkg_size, bkg_size), "valid");
  [~, min_idx] = min (conv_matrix(:));

  ## start and end coordinates of the region
  [iRow, iCol] = ind2sub (size (conv_matrix), min_idx);
  fRow = iRow + bkg_size-1;
  fCol = iCol + bkg_size-1;

  ## Create mask for the background region and get a mask for its borders
  mask = false (size (img));
  mask (iRow:fRow, iCol:fCol) = true;
  perim = bwperim (mask);
endfunction

function [perim, ind] = find_bleach (img)
  ## we used a disk with radius of 20 pixels
  radius = 20;
  ## How much bigger will be the analyzed bleach area than the bleach spot
  bleach_factor = 1.25;

  disk = fspecial ("disk", radius);

  ## Find minimum of the convolution matrix
  conv_matrix  = conv2 (img, disk, "same");
  [~, ind] = max (conv_matrix(:));

  ## start and end coordinates of the region
  [r, c] = ind2sub (size (conv_matrix), ind);
  mask = false (size (img));
  mask(r-radius : r+radius, c-radius : c+radius) = disk > 0;
  perim = bwperim (mask);
endfunction

function [perim] = find_nucleus (img, bleach)
  thresh = graythresh (img);
  mask   = im2bw (img, thresh);

  for op = {"erode", "dilate", "dilate", "erode"}
    mask = bwmorph (mask, op{:});
  endfor
  mask = bwfill (mask, "holes");

  ## For multiple nucleus, pick one based on the bleach spot coordinates
  [r, c] = ind2sub (size (img), bleach);

  # Create mask for the bleached cell nucleus using the bleach coordinates to find the right object
  clean_mask = bwselect (mask, c, r);
  perim = bwperim (clean_mask);
endfunction

img  = im2double (img);
pre  = mean (img(:,:,:, 51:100), 4);
post = mean (img(:,:,:,101:105), 4);

sub = pre - post;
sub(sub < 0) = 0;

[background] = find_background (pre);
[bleach, coord] = find_bleach (sub);
[nucleus] = find_nucleus (pre, coord);

## adjust image intensity for display. Only up to 75% of the range
## so that the ROI borders can be seen when set to white.
pre  = im2uint8 (imadjust (pre)  * 0.5);
post = im2uint8 (imadjust (post) * 0.5);
sub  = im2uint8 (imadjust (sub)  * 0.5);

imwrite (pre,  fpre);
imwrite (post, fpost);
imwrite (sub,  fsub);

pre(background | bleach | nucleus) = getrangefromclass (pre)(2);
imwrite (pre, fsel);

