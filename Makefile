SRC_DIR = src
EBIN_DIR = ebin
INCLUDE_DIR = include
PKGNAME=erl_openid

MODULES=$(shell ls -1 src/*.erl | awk -F[/.] '{ print "\t\t" $$2 }' | sed '$$q;s/$$/,/g')

SOURCES  = $(wildcard $(SRC_DIR)/*.erl)
INCLUDES = $(wildcard $(INCLUDE_DIR)/*.hrl)
TARGETS  = $(patsubst $(SRC_DIR)/%.erl, $(EBIN_DIR)/%.beam,$(SOURCES))

ERL_EBINS = -pa $(EBIN_DIR)

ERLC = erlc
ERLC_OPTS = -o $(EBIN_DIR) -Wall -v +debug_info

ERL_CMD=erl \
	+W w \
	$(ERL_EBINS)

all: app $(TARGETS)

app: ebin/$(PKGNAME).app

ebin/$(PKGNAME).app: src/$(PKGNAME).app.src
	@sed -e 's/{modules, \[\]}/{modules, [$(MODULES)]}/' < $< > $@
	
run_prereqs: all

test: run_prereqs
	$(ERL_CMD) -noshell -pa ../mochiweb/ebin -s openid_srv test -s init stop

clean: cleanlog
	rm -f $(TARGETS)
	rm -f $(EBIN_DIR)/*.beam

cleanlog:
	rm -f auth.log report.log sasl_err.log
	rm -f *.access

$(EBIN_DIR)/%.beam: $(SRC_DIR)/%.erl $(INCLUDES)
	$(ERLC) $(ERLC_OPTS) $<
