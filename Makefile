DATA         = $(wildcard sql/*.sql)
DOCS         = $(wildcard doc/*.*)
MODULES      = $(patsubst %.c,%,$(wildcard src/*.c))

TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test

PG_CONFIG   ?= pg_config
PGXS        := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
