# Global variables {{{1
# ================
# Where make should look for things
VPATH = _lib
vpath %.yaml .:_spec
vpath %.bib .:bibliography

DOCS = $(wildcard docs/*.md)
_PAGES := $(patsubst _pages/*.md,docs/*.md,$(DOCS))

# Branch-specific targets and recipes {{{1
# ===================================
_site: $(_PAGES)
	docker run --rm -v "`pwd`:/srv/jekyll" \
		jekyll/jekyll:3.8.5 /bin/bash -c \
		"chmod 777 /srv/jekyll && jekyll build --future"

.PHONY : serve
serve: $(_PAGES)
	docker run --rm -v "`pwd`:/srv/jekyll" \
		-h "0.0.0.0:127.0.0.1" -p "4000:4000" \
		jekyll/jekyll:3.8.5 jekyll serve --future

_pages/%.md : docs/%.md biblio.bib html.yaml
	pandoc -t markdown -o $@ \
		-d _spec/html.yaml $<

%.pdf : %.md biblio.bib pdf.yaml
	docker run --rm -v "`pwd`:/data" --user `id -u`:`id -g` \
		pandoc/latex:2.17.1.1 $< -d spec/pdf.yaml -o $@

%.md : docx2md.yaml %.docx
	docker run --user "`id -u`:`id -g`" \
		-v "`pwd`:/data" pandoc/core:2.14.2 \
		-o $@ -d $^

# Install and cleanup {{{1
# ===================

clean :
	-rm -r styles .*.lb *.aux *.bbl *.bcf *.blg *-blx.aux *-blx.bib *.cb \
		*.cb2 *.dvi *.fls *.fmt *.fot *.lof *.log *.lot *.out *.run.xml \
		*.toc *.xdv

# vim: set foldmethod=marker :
