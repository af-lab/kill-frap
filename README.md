Kill FRAP
=========

We tried to use FRAP to measure differences in dynamics between
histone mutants but that didn't really work.

File structure
--------------

* `data` - the raw data.  Almost empty on a fresh clone because the
  files are too large.  Contact David Pinto (author) or Andrew Flaus
  (PhD supervisor) to obtain those files.  SCons will use checksums to
  make sure you got the right files and that they didn't got
  corrupted.
* `figs` - figures that are not generated as part of the analysis.
* `results` - figures that are generated as part of the analysis.
* `scripts` - code for the analysis.  Fills `results` with stuff from
  `data`.
