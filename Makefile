# Global variables {{{1
# ================
# Where make should look for things
VPATH = _lib
vpath %.yaml .:_spec:_data
vpath %.bib .:bibliography

DOCS  = $(wildcard _docs/*.md)
PAGES = $(patsubst _docs/%.md,_pages/%.md,$(DOCS))

# Branch-specific targets and recipes {{{1
# ===================================
.PHONY : _site
_site: $(PAGES)
	@docker run --rm -v "`pwd`:/srv/jekyll" \
		jekyll/jekyll:3.8.5 /bin/bash -c \
		"chmod 777 /srv/jekyll && jekyll build --future"

.PHONY : serve
serve: $(PAGES)
	@docker run --rm -v "`pwd`:/srv/jekyll" \
		-h "0.0.0.0:127.0.0.1" -p "4000:4000" \
		jekyll/jekyll:3.8.5 jekyll serve --future

_pages/%.md : docs/%.md biblio.yaml html.yaml
	@-mkdir -p _pages
	@pandoc -o $@ -d _spec/html.yaml $<
	@echo "$@"

%.pdf : %.md biblio.bib pdf.yaml
	@docker run --rm -v "`pwd`:/data" --user `id -u`:`id -g` \
		pandoc/latex:2.18 $< -d spec/pdf.yaml -o $@
	@echo "$@"

%.md : docx2md.yaml %.docx
	@docker run --user "`id -u`:`id -g`" \
		-v "`pwd`:/data" pandoc/core:2.18 \
		-o $@ -d $^
	@echo "$@"

# Install and cleanup {{{1
# ===================

.PHONY : clean
clean :
	-rm -r styles .*.lb *.aux *.bbl *.bcf *.blg *-blx.aux *-blx.bib *.cb \
		*.cb2 *.dvi *.fls *.fmt *.fot *.lof *.log *.lot *.out *.run.xml \
		*.toc *.xdv

# vim: set foldmethod=marker :
