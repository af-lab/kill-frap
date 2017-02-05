#!/usr/local/bin/octave -qf
##
## Copyright (C) 2014-2017 Carnë Draug <carandraug+dev@gmail.com>
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

function seed = Crop_Reg (img, seed, rect, ratio)

  nFrames = size (img, 4);
  img     = squeeze (img); # just for less typing ":"
  rimg    = rows (img);
  cimg    = columns (img);

  ## expand output image for all the frames
  seed = resize (seed, rows (seed), columns (seed), nFrames);

  ## There are two boxes we need to keep track of:
  ##  1) seed = the box with what we will return
  ##  2) search = the slightly larger box where we will be looking
  ##
  ## At any given time, there will be a position vector defining those
  ## boxes relative to the input original image:
  ##    v(1) = x_ini
  ##    v(2) = y_ini
  ##    v(3) = width
  ##    v(4) = length

  ## position vector for the seed
  vseed = [round(rect([1 2])) size(seed)([2 1])];

  ## position vector for the search
  pad = round ((vseed(3:4) * ratio));
  vsearch(3:4) = vseed(3:4) + pad*2;

  for frame = 2:nFrames

    ## readjust the search box and confirm it is still within the limits
    vsearch(1:2) = vseed(1:2) - pad;
    if (vsearch(1) + vsearch(3) > cimg || vsearch(1) < 1 ||
        vsearch(2) + vsearch(4) > rimg || vsearch(2) < 1 )
      ## we could readjust this if in the future we get objects moving
      ## near the borders that we want to track. At the moment, all our
      ## cases still move within the center
      error ("CropReg: object is moving outside of the image")
    endif

    ## look into the search box for the image found on the previous frame
    csr = vsearch(1) : vsearch(1)+vsearch(3)-1;
    rsr = vsearch(2) : vsearch(2)+vsearch(4)-1;
    xc2 = normxcorr2 (seed(:,:,frame-1), img(rsr,csr,frame));

    [~, max_idx] = max (xc2(:));
    [m, n] = ind2sub (size (xc2), max_idx);

    ## recalculate the initial x and y coordinates for the seed
    vseed(1) = vsearch(1) + n - vseed(3);
    vseed(2) = vsearch(2) + m - vseed(4);

    csd = vseed(1) : vseed(1)+vseed(3)-1;
    rsd = vseed(2) : vseed(2)+vseed(4)-1;
    seed(:,:,frame) = img(rsd, csd, frame);
  endfor

  ## put it back into 4D matrix for writing
  seed = reshape (seed, [size(seed)(1:2) 1 nFrames]);

endfunction

function aligned = stackreg (img)
  ## This is ridiculous but I can't figure out how to do it in a nicer
  ## way.  In theory, we should be able to just create an ImagePlus
  ## object and then call some method in StackReg with it.  But
  ## StackReg only has the run method which will create a dialog and
  ## works on the currently open image.

  ## ImageJ plugins dir defaults to "../plugins", relative to the
  ## location of ij.jar (if documnetation is to be believed).
  ## However, that does not happen in Debian and Ubuntu so make this
  ## configurable with environment variables.
  imagej_pluginsdir = getenv ("IMAGEJ_PLUGINSDIR");
  if (! isempty (imagej_pluginsdir))
    javaMethod ("setProperty", "java.lang.System",
                "plugins.dir", imagej_pluginsdir);
  endif

  imagej = javaObject ("ij.ImageJ", java_get ("ij.ImageJ", "NO_SHOW"));
  if (! javaMethod("getCommands", "ij.Menus").containsKey ("StackReg "))
    error ("stackreg: did not found 'StackReg ' command in ImageJ");
  endif

  ## Going from an Octave array to an ImagePlus object seems way too
  ## complicated.  And I can't figure out how to use ShortProcessor
  ## from Octave.  This is easier.
  f_tracked = [tempname() ".tif"];
  imwrite (img, f_tracked);

  ## I can't figure out how to enter batch mode and not have the image
  ## window be displayed.  I can get it return an ImagePlus object but
  ## then I can't use it on StackReg.  Not that it matters anyway
  ## since we are using xvfb.
  javaMethod ("open", "ij.IJ", f_tracked);
  javaMethod ("runMacro", "ij.IJ",
              "run('StackReg ', 'transformation=[Rigid Body]');");

  ## Is there a way to get the pixel values from an ImageJPlus other
  ## than loopig every single one?
  f_aligned = [tempname() ".tif"];
  javaMethod ("save", "ij.IJ", f_aligned);
  aligned = imread (f_aligned, "Index", "all");

  unlink (f_tracked); # if it fails, it's in /tmp so who cares?
  unlink (f_aligned); # if it fails, it's in /tmp so who cares?
endfunction

function main (argv)
  montage_size = [5 3];

  if (numel (argv ()) != 2)
    error ("Requires exactly 2 arguments")
  endif
  in_img  = argv (){1};
  out_img = argv (){2};

  img = imread_dv (in_img);

  ## the image has been deconvolved so we need to trim the borders
  img = img(31:end-30,31:end-30,:,:);

  img = imadjust (img, stretchlim (img(:,:,:,1), 0));

  rect = [570   250   280   300];
  [seed, rect] = imcrop (img(:,:,:,1), rect);
  tracked = Crop_Reg (img, seed, rect, 0.2);
  aligned = stackreg (tracked);

  ## inset the aligned image on the top left corner of the corresponding
  ## frame, with a small white border around it
  aligned = padarray (aligned, [5 5], getrangefromclass (aligned)(2), "post");
  img(1:rows (aligned), 1:columns (aligned),:,:) = aligned;

  ## add an arrow to the image, pointing to the cell being tracked,
  ## but only on the first frame
  arrow = imdilate (logical (eye (100)), strel ("square", 5));
  arrow(end-49:end, end-49:end) |= logical (imrotate (tril (ones(50)), 90));
  [r, c] = find (arrow);
  ind    = sub2ind (size (img), r + rect(2) -50, c + rect(1) -50);
  img(ind) = getrangefromclass (img)(2);

  mont_img = montage_cdata (img,
    "Size", montage_size,
    "MarginWidth", 10,
    "Indices", [1 2:2:size(img, 4)](1:prod (montage_size))
  );
  imwrite (mont_img, out_img);
endfunction

main (argv ());
