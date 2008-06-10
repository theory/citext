MODULES = citext
DATA_built = citext.sql
DOCS = README.citext
REGRESS = citext

top_builddir = ../..
in_contrib = $(wildcard $(top_builddir)/src/Makefile.global);

ifdef $(in_contrib)
	# Just include the local makefiles
	subdir = contrib/citext
	include $(top_builddir)/src/Makefile.global
	include $(top_srcdir)/contrib/contrib-global.mk
else
	# Use pg_config to find PGXS and include it.
	PGXS := $(shell pg_config --pgxs)
	include $(PGXS)
endif

test:
	`pg_config --bindir`/pg_prove sql/$(REGRESS).sql
