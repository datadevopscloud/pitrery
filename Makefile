# See COPYRIGHT file for copyright and license details.

include config.mk

SRCS = archive_xlog.bash \
	create_standby.bash \
	pitr_mgr.bash \
	restore_xlog.bash
HELPERS = backup_pitr.bash \
	list_pitr.bash \
	purge_pitr.bash \
	restore_pitr.bash
SRCCONFS = archive_nodes.conf.sample \
	archive_xlog.conf.sample \
	create_standby.conf.sample \
	pitr.conf.sample

BINS = $(basename $(SRCS))
LIBS = $(basename $(HELPERS))
CONFS = $(basename $(SRCCONFS))

all: options $(BINS) $(LIBS) $(CONFS)

options:
	@echo ${NAME} install options:
	@echo "PREFIX     = ${PREFIX}"
	@echo "BINDIR     = ${BINDIR}"
	@echo "LIBDIR     = ${LIBDIR}"
	@echo "SYSCONFDIR = ${SYSCONFDIR}"
	@echo

$(BINS) $(LIBS): $(SRCS)
	@echo translating paths in bash scripts
	@sed -e "s%@BASH@%${BASH}%" \
		-e "s%@SYSCONFDIR@%${SYSCONFDIR}/${NAME}%" \
		-e "s%@LIBDIR@%${LIBDIR}/${NAME}%" $(addsuffix .bash,$@) > $@

$(CONFS): $(SRCCONFS)
	@echo translating paths in configuration files
	@sed -e "s%@SYSCONFDIR@%${SYSCONFDIR}/${NAME}%" \
		-e "s%@LIBDIR@%${LIBDIR}/${NAME}%" $(addsuffix .sample,$@) > $@

clean:
	@echo cleaning
	@-rm -f $(BINS)
	@-rm -f $(LIBS)
	@-rm -f $(CONFS)

install: all
	@echo installing executable files to ${DESTDIR}${BINDIR}
	@mkdir -p ${DESTDIR}${BINDIR}
	@cp -f $(BINS) ${DESTDIR}${BINDIR}
	@chmod 755 $(addprefix ${DESTDIR}${BINDIR}/,$(BINS))
	@echo installing helpers to ${DESTDIR}${LIBDIR}
	@mkdir -p ${DESTDIR}${LIBDIR}
	@cp -f $(LIBS) ${DESTDIR}${LIBDIR}
	@chmod 755 $(addprefix ${DESTDIR}${LIBDIR}/,$(LIBS))
	@echo installing configuration to ${DESTDIR}${SYSCONFDIR}
	@mkdir -p ${DESTDIR}${SYSCONFDIR}
	@cp -i $(CONFS) ${DESTDIR}${SYSCONFDIR} < /dev/null >/dev/null 2>&1

uninstall:
	@echo removing executable files from ${DESTDIR}${BINDIR}
	@rm -f $(addprefix ${DESTDIR}${BINDIR}/,$(BINS))
	@echo removing helpers from ${DESTDIR}${LIBDIR}
	@rm -f $(addprefix ${DESTDIR}${LIBDIR}/,$(LIBS))
	@-rmdir ${DESTDIR}${LIBDIR}

.PHONY: all options clean install uninstall
