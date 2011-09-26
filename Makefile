# based on the Makefile for jquery

SRC_DIR = src
TEST_DIR = test
BUILD_DIR = build

PREFIX = .
DIST_DIR = ${PREFIX}/dist

JS_ENGINE ?= `which node nodejs`
COMPILER = ${JS_ENGINE} ${BUILD_DIR}/uglify.js --unsafe
POST_COMPILER = ${JS_ENGINE} ${BUILD_DIR}/post-compile.js

BASE_FILES = ${SRC_DIR}/core.coffee \
			${SRC_DIR}/data.coffee \
			${SRC_DIR}/expression.coffee \
			${SRC_DIR}/presentation.coffee \
			${SRC_DIR}/facet.coffee \
			${SRC_DIR}/application.coffee \
			${SRC_DIR}/plugin.coffee

MODULES = ${SRC_DIR}/intro.coffee \
		${BASE_FILES} \
		${SRC_DIR}/outro.coffee

MG = ${DIST_DIR}/mithgrid.js
MG_MIN = ${DIST_DIR}/mithgrid.min.js
MG_C = ${DIST_DIR}/mithgrid.coffee

MG_VER = $(shell cat version.txt)
VER = sed "s/@VERSION/${MG_VER}/"

DATE=$(shell git log --pretty=format:%ad | head -1)

all: core

core: mithgrid min lint
		@@echo "mithgrid build complete"

${DIST_DIR}:
		@@mkdir -p ${DIST_DIR}

mithgrid: ${MG}

#| \
#sed 's/.function....MITHGrid..{//' | \
#sed 's/}..jQuery..MITHGrid.;//' > ${MG}.tmp;

${MG_C}: ${MODULES} | ${DIST_DIR}
		@@echo "Building" ${MG_C}
		
		@@cat ${BASE_FILES} > ${MG_C}.tmp;
		
		@@cat ${SRC_DIR}/intro.coffee ${MG_C}.tmp ${SRC_DIR}/outro.coffee | \
			sed 's/@DATE/'"${DATE}"'/' | \
			${VER} > ${MG_C};
		@@rm -f ${MG_C}.tmp;

${MG}: ${MG_C}
		@@coffee -c ${MG_C};

lint: mithgrid
		@@if test ! -z ${JS_ENGINE}; then \
				echo "Checking mithgrid against JSLint..."; \
				${JS_ENGINE} build/jslint-check.js; \
		else \
				echo "You must have NodeJS installed in order to test mithgrid against JSLint."; \
		fi

min: mithgrid ${MG_MIN}

${MG_MIN}: ${MG}
		@@if test ! -z ${JS_ENGINE}; then \
				echo "Minifying mithgrid" ${MG_MIN}; \
				echo "/*" > ${MG_MIN}; \
				cat ${MG_C} | awk '/###/ { i = i + 1; l = 0 }; l = l + 1 { }; (i ~ 1 && l !~ 1) { print  }' >> ${MG_MIN}; \
				echo " */" >> ${MG_MIN}; \
				${COMPILER} ${MG} > ${MG_MIN}.tmp; \
				${POST_COMPILER} ${MG_MIN}.tmp >> ${MG_MIN}; \
				rm -f ${MG_MIN}.tmp; \
		else \
				echo "You must have NodeJS installed in order to minify mithgrid."; \
		fi

clean:
		@@echo "Removing Distribution directory:" ${DIST_DIR}
		@@rm -rf ${DIST_DIR}

distclean: clean

.PHONY: all mithgrid lint min clean distclean core
