# Choose the target by uncommenting just one "paper" definition here.
# NOTE:  To process supp-aoas, you need to have already processed paper-aoas
# and left its aux file in place.

#paper=paper-arxiv
#paper=paper-aoas
paper=supp-aoas

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

view:  $(paper).pdf
ifeq ($(UNAME),Darwin)
	open -a Skim $(paper).pdf
else
	acroread -openInNewWindow -geometry 800x825 $(paper).pdf &
endif

# "make refs" requires a local copy of the .bst file.
# Creates refs-gather-bbl.tex for pasting into bibliography environment.
refs:  $(paper).tex UHECR.bib
	bibtex $(paper)
	# mv $(paper).bbl $(paper)-bbl.tex
	echo '***** FIX YEARS IN REFS!!! *****'

clean:
	rm -f $(paper).nav $(paper).out $(paper).snm $(paper).toc \
	   $(paper).aux $(paper).dvi $(paper).log $(paper).synctex.gz \
	   $(paper).spl p.ps

# Bundling targets:
#
# The file lists are partly found using tex_file_list.py.

ARXIV_FIGS = CR+LocalAGN-all.eps CR+LocalAGN-1-nobar.eps CR+LocalAGN-2-nobar.eps CR+LocalAGN-3.eps CRCoincLevels2.eps BF_kappa_17AGNs_1+2.eps postf.eps kappa_f-log_kappa.eps posterior_f_all_margOverKappa.eps posterior_FT_all_margOverKappa.eps BF_cumplot_genUnif_14CRs_logscale.eps BFCumplot-AssocnSimn.eps avg_pjxn_factor.eps BF-CenAvsIsotropic-SmallKappa.eps margf_kappa1000_17AGNs.eps BF_changepoint_17AGNs.eps BF_changepoint_2AGNs.eps
ARXIV_INPUTS = intro-arxiv.tex data-arxiv.tex modeling-arxiv.tex results-arxiv.tex checking-arxiv.tex discussion.tex app-exposure.tex app-like.tex app-computation.tex app-CenA.tex app-comparison.tex app-chgpt-arxiv.tex

arxiv:
	tar czf arxiv.tgz paper-arxiv.tex paper-arxiv.bbl imsart.sty imsart.cls \
	$(ARXIV_INPUTS) $(ARXIV_FIGS)
	mkdir test
	tar -C test -xf arxiv.tgz

AOAS_FIGS = CR+LocalAGN-all.eps CRCoincLevels2.eps BF_kappa_17AGNs_1+2.eps postf.eps kappa_f-log_kappa.eps posterior_f_all_margOverKappa.eps posterior_FT_all_margOverKappa.eps avg_pjxn_factor.eps BF-CenAvsIsotropic-SmallKappa.eps margf_kappa1000_17AGNs.eps BF_changepoint_17AGNs.eps BF_changepoint_2AGNs.eps BF_cumplot_genUnif_14CRs_logscale.eps BFCumplot-AssocnSimn.eps
AOAS_INPUTS = intro-aoas.tex data-aoas.tex modeling-aoas.tex results-aoas.tex discussion.tex app-exposure.tex app-like.tex app-computation.tex app-CenA.tex app-comparison.tex app-checking-aoas.tex

aoas:
	tar czf aoas.tgz paper-aoas.tex paper-aoas.bbl supp-aoas.tex supp-aoas.bbl \
	imsart.sty imsart.cls $(AOAS_INPUTS) $(AOAS_FIGS)
	mkdir test
	tar -C test -xf aoas.tgz
