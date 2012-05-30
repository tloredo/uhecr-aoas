paper=paper

# This uses dvips; PDF figs not supported.

# Add "--interaction=nonstopmode" to skip latex warnings, e.g., missing citations

# Use "make paper" to make a PDF version of the paper using the
# simpdftexnodel script, which will run latex the right number of times
# to handle references, etc.
#
# If there is no simpdftexnodel, use "make dvi2pdf" to run latex twice
# and then convert the DVI file to PS and then to PDF.
#
# On linux and Mac OS X, you can instead use "make view" to first run
# "make paper" and then open the PDF file in a viewer (acroread on linux,
# or the system default PDF viewer on OS X).


# Possible platform-detection methods:
# UNAME := $(shell uname)  [values are Darwin, Linux, Solaris...]
# See http://stackoverflow.com/questions/714100/os-detecting-makefile
#
# HOST_PLATFORM = ${shell $(CPP) -dumpmachine}  [gives i686-apple-darwin10 for OS 10.6]
#
# To determine address space size:
# LBITS := $(shell getconf LONG_BIT)
#
# Use info in:
# ifeq ($(VAR),VALUE)
#	DO THIS
# else
#	DO THAT
# endif

SYNCOPT =
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
    # Set the SyncTeX option for simpdftex on OS X
    SYNCOPT = --extratexopts "-synctex=1"
endif

# Use "make dvi2pdf" if you don't have simpdftexnodel.
# The  dvips options address improper rendering of ligatures for some font
# installations, and a security issue in some OS X TeX installations.
dvi2pdf:  $(paper).tex
	latex $(paper)
	latex $(paper)
	dvips -R0 -Ppdf -z -G0 -o $(paper).ps $(paper)
	ps2pdf $(paper).ps
	rm -rf $(paper).ps head.tmp body.tmp

# simpdftexnodel is a version of simpdftex that updates rather than deletes
# the PDF file, so viewers can refresh rather than reload updated PDF output.
# See http://phaseportrait.blogspot.com/2007/07/skim-automatic-refreshes-and-simpdftex.html
paper:  $(paper).tex
	simpdftexnodel latex $(SYNCOPT) $(paper)
	rm -f head.tmp body.tmp

view:  paper
ifeq ($(UNAME),Darwin)
	open -a Skim $(paper).pdf
else
	acroread -openInNewWindow -geometry 800x825 $(paper).pdf &
endif

# "make refs" requires a local copy of the .bst file.
# Creates refs-gather-bbl.tex for pasting into bibliography environment.
refs:  $(paper).tex UHECR.bib
	bibtex $(paper)
	mv $(paper).bbl $(paper)-bbl.tex
	echo '***** FIX YEARS IN REFS!!! *****'

clean:
	rm -f $(paper).nav $(paper).out $(paper).snm $(paper).toc \
	   $(paper).aux $(paper).dvi $(paper).log $(paper).synctex.gz \
	   $(paper).spl p.ps
