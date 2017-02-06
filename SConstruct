#!/usr/bin/env python
# -*- coding: utf-8 -*-

## Copyright 2014-2017 David Miguel Susano Pinto
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

import os.path
import subprocess
import json
import hashlib

env = Environment()


vars = Variables()

vars.Add('OCTAVE', default='octave',
         help='The Octave interpreter')

vars.Add('IMAGEJ_PLUGINSDIR', default='/usr/share/imagej/plugins/',
         help='Value for ImageJ plugins.dir')

vars.Update(env)
Help(vars.GenerateHelpText(env))


AddOption(
  "--verbose",
  dest    = "verbose",
  action  = "store_true",
  default = False,
  help    = "Print LaTeX and BibTeX output."
)

if not env.GetOption("verbose"):
  env.AppendUnique(PDFLATEXFLAGS  = "-interaction=batchmode")
  env.AppendUnique(PDFTEXFLAGS    = "-interaction=batchmode")
  env.AppendUnique(TEXFLAGS       = "-interaction=batchmode")
  env.AppendUnique(LATEXFLAGS     = "-interaction=batchmode")
  env.AppendUnique(BIBTEXFLAGS    = "--terse")  # some ports of BibTeX may use --quiet instead


## Simple Builder to call Octave scripts.  Note that the targets are
## all in a single command.
def octave_script(env, script, source, target, args=[]):
  script = env.File(script)
  octave_path = env.Dir('lib-octave')
  c = env.Command(target, source, SCRIPT=script, OCTAVE_PATH=octave_path,
                  action='$OCTAVE -W --quiet --path $OCTAVE_PATH $SCRIPT $SOURCE $TARGETS')
  env.Depends(c, [script])
  return c

def octave_with_imagej(env, script, source, target, args=[]):
  script = env.File(script)
  octave_path = env.Dir('lib-octave')
  c = env.Command(target, source, SCRIPT=script, OCTAVE_PATH=octave_path,
                  action='IMAGEJ_PLUGINSDIR=$IMAGEJ_PLUGINSDIR'
                         ' xvfb-run $OCTAVE --quiet --path $OCTAVE_PATH'
                         ' $SCRIPT $SOURCE $TARGETS')
  env.Depends(c, [script])
  return c

env.AddMethod(octave_script, "OctaveScript")
env.AddMethod(octave_with_imagej, "OctaveWithImageJ")


def path4script(fname=""):
  return os.path.join("scripts", fname)
def path4data(fname=""):
  return os.path.join("data", fname)
def path4result(fname=""):
  return os.path.join("results", fname)

figures = [
  env.OctaveScript(
    script = path4script("roi.m"),
    source = path4data("Location8Cell1.lsm"),
    target = [path4result(f) for f in ["roi-prebleach.png", "roi-postbleach.png",
                                       "roi-subtracted.png", "roi-selected.png"]],
  ),
  env.OctaveScript(
    script = path4script("confluent.m"),
    source = path4data("H4 R45H_L3_Sum.lsm"),
    target = path4result("confluent-hela.png"),
  ),
  env.OctaveScript(
    script = path4script("horse.m"),
    source = path4data("Horse_confluent_H2B-GFP_01_08_R3D_D3D.dv"),
    target = path4result("confluent-horse.png"),
  ),
  env.OctaveScript(
    script = path4script("ifrap.m"),
    source = path4data("HeLa_H2B-PAGFP_01_12_R3D_D3D.dv"),
    target = [path4result(f) for f in ['ifrap-pre.png', 'ifrap-post.png',
                                       'ifrap.png']],
  ),
  env.Command(
    source = [path4script("frapinator.sh"), path4data("frapinator-options.txt"),
              path4data("Image114.lsm")],
    target = [path4result('frapinator.png'),
              path4result('frapinator-data.txt')],
    action = '$SOURCES $TARGETS',
  ),
  env.OctaveWithImageJ(
    script = path4script("cropreg.m"),
    source = path4data("HeLa_H3_1A5_01_6_R3D_D3D.dv"),
    target = path4result("cropreg.png"),
  ),
]

env.Alias("figures", figures)


##
## manuscript (default target)
##

manuscript = env.PDF(target="kill-frap.pdf", source="kill-frap.tex")
env.Alias("kill-frap", manuscript)
Depends(manuscript, [figures])

env.Default(manuscript)


##
## "Configure" - check that we have all the required tools installed
##

def CheckProg(context, prog_name):
  context.Message("Checking for %s..." % prog_name)
  is_ok = context.env.WhereIs(prog_name)
  context.Result(is_ok)
  return is_ok

def CheckOctavePackage(context, pkg):
    context.Message("Checking for Octave package %s..." % pkg)
    is_ok = (subprocess.call(["octave", "-qf", "--eval", "pkg load " + pkg]) == 0)
    context.Result(is_ok)
    return is_ok

def CheckDataMD5(context, md5s):
  context.Message("Checking for kill-frap data files integrity...")

  for fpath, md5 in md5s.iteritems():
    read_md5 = hashlib.md5(open(fpath, "rb").read()).hexdigest()
    if md5 != read_md5:
      context.Result("failed for " + fpath)
      return False
  else:
    context.Result(True)
    return True

def CheckIJinJavaClasspath(context):
  context.Message("Checking if ImageJ (ij.jar) is in Octave's javaclasspath...")
  cmd = 'try javaMethod ("getVersion", "ij.IJ"); catch exit (1) end'
  is_ok = (subprocess.call(["octave", "-qf", "--eval", cmd]) == 0)
  context.Result(is_ok)
  return is_ok

conf = Configure (
  env,
  custom_tests = {
    "CheckProg" : CheckProg,
    "CheckOctavePackage" : CheckOctavePackage,
    "CheckDataMD5" : CheckDataMD5,
    "CheckIJinJavaClasspath" : CheckIJinJavaClasspath,
  },
)

## Seriously, this should be the default.  Otherwise, users won't even
## get to see the help text  unless they pass the configure tests.
## And Configure(..., clean=False,help=False) does not really work,
## it just makes all configure tests fail.
if not (env.GetOption('help') or env.GetOption('clean')):
  progs = {
    "octave"
      : "GNU Octave must be installed",
    "xvfb-run"
      : "xvfb-run is needed because of ImageJ",
  }

  for p_name, p_desc in progs.iteritems():
    if not conf.CheckProg(p_name):
      print p_desc
      Exit(1)

  for pkg in ['image', 'bioformats']:
    if not conf.CheckOctavePackage(pkg):
      print "Octave's %s package must be installed" % pkg
      Exit(1)

  with open(path4data("data-md5.json"), "r") as fid:
    data_md5s = json.load(fid)
  data_md5s = {path4data(fname) : md5 for fname, md5 in data_md5s.iteritems()}

  for fpath in data_md5s.keys():
    if not os.path.isfile(fpath):
      print "Missing data file " + fpath
      Exit(1)

  if not conf.CheckIJinJavaClasspath():
    print "ImageJ (ij.jar) is not in Octave's javaclasspath"
    Exit(1)

  ## I guess we should also have a configure check for ImageJ commands
  ## because of StackReg.

  if not conf.CheckDataMD5(data_md5s):
    print "Found corrupt or incorrect data file"
    Exit(1)

env = conf.Finish()
