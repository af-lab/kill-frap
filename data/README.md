Data sets used for the results
==============================

This directory is mostly empty due to space constraints. Some of the images
used to generate the results in the thesis are above 600MB in size, and even
the smaller are still too commit to the repository.

Ideally, we would have those images in a public accessible database and
download them during build time. However, HEAnet will be pulling the plug on
our omero server so that won't work. In case of emergency, those files can
be found in the 4big under the `carandraug` directory.

So, for a correct build of the thesis, the following files will needed to
be copied into the `data` directory (the hash in front of their names is the
corresponding md5sum):

* `Location8Cell1.lsm` (bca6b27a3b165bac348622dd24cd8f25) which will be in a
directory named `2010-04-28 H4 R45H (11h after mitosis) 20px circle and 30ms scan and laser 7 2500frames`.
This image will be used to show the automatic identification of ROIs.

* `Image114.lsm` (0a616796e0fbed9cd6783087947c60dc) which will be in a
directory named `2010-04-29 H3 T45E (no cell cycle check) Laser 5 Scan 30ms Interval 0msc Frames 2500 Diameter 20`.
This image will be used to create the FRAPINATOR plots.

* `H4 R45H_L3_Sum.lsm` (cc0b48e579cb8a9f9b0fc02662f7b071) which will be in a
directory named `2010-02-03 H4 R45H slow recovery`. This image will be used
to display cell movement with confluent cells.

* `Horse_confluent_H2B-GFP_01_08_R3D_D3D.dv` (e12034459ac256d3ec70c635a1d68cea)
which will be in a directory named `horse/2011-05-02_Horse_H2B-GFP` of the
images taken in the DeltaVision. This image will be used to display cell
movement of the horse cells, even after reaching confluence.

* `HeLa_H3_1A5_01_6_R3D_D3D.dv` (5ff55aaabf55cd3c4c9cc9ceaa1ebc7d) which will
be in a directory named `cell_movement/2011-05-03_HeLa_H3_1A5` of the images
taken in the DeltaVision. This image will be used to display CropReg in action.

* `HeLa_H2B-PAGFP_01_12_R3D_D3D.dv` (e6de2c8bd8be05401a4a01350493f3e0) which
will be in a directory named `reverse_FRAP/2011-05-04_HeLa_H2B-PAGFP` of the
images taken in the DeltaVision. This image will be used to display the
chromatin movement via inverse FRAP.

More information about the images should be found on its metadata.

In addition, the following FACS files were required to draw the FACS histogram
at `figs/facs-stable-cell-lines.svg`. Due to the absence of libraries for
reading of fcs files, the plots were generated manually in a point and click
software, exported to SVG, opened in Inkscape to change the line styles to
solid, dashed, and dotted, which then saved it as PDF.

* `WT_Tube_001.fcs` (456312e7f75f38a7e4968421b1b41a9b) for the histogram of
HeLa cells wild type.

* `H2B 11_Tube_001.fcs` (ac1f23b84e758f033b2ccaa293e51801) for the histogram
of the mixed population expressing H2B EGFP.

* `clone check H2B 2P3_Tube_001.fcs` (ce930978f86f7fb6f453157cc7b2dc4c) for
the histogram of the sorted population.

