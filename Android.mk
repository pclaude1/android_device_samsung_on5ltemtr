
#
# Global configuration file for all makefiles.
#
# The variables in this file can be overridden in a file name config.local.mk
# exist in the ROOT directory.  Such a file should not be checked into the tree
#
# This should be sourced by setting the make variable ROOT to a relative path
# to the top of the tree and then including this file.
#
#    ROOT = ..
#    include ${ROOT}/config.mk
#    <local variable definitions>
#    ...
#    include ${ROOT}/rules.mk
#    <local rules definitions>
#
# To compile programs that use the G-Known source base, but are not part
# of the tree, set GK_ROOT to the top of the G-Known tree then
# include this file.  Use ROOT to point to the root for the program.
#
# This requires GNU make.
#
# Note: To generate an mixed C/C++ and assembly listing with GCC, use
# the options: -g -Wa,-alhs
#
# Optional software: 
#   Optional software packages are found via make variables that point
# to the include and library files.  Normally, the make variables have defaults
# that are set in this file and maybe overridden in config.local.mk.  The
# wildcard function is used to determine if the package is installed before
# compiling.
#
# Warning automatic check for files is broken because wildcard with a variable
# reference doesn't work in make 3.79.1, so we make some assumptions here
# 
#   - plotutils - GNU plotutils package, which provides libplot.  Used by
#     predict-plot.  Must be built with C++ support.
#       - HAVE_PLOTUTILS - Set to YES if the other variables are set.
#       - PLOTUTILS_INCL_DIR - location of the plotter.h and plot.h files
#       - PLOTUTILS_LIB_DIR - location of the libplot library
#    These default to looking in ${ROOT}/tools/${ARCH}
#

# remove spaces from architecture name ("Power Macintosh" => "PowerMacintosh")
ARCH = $(shell uname -m | sed -e 's/ //g')

SYS = $(shell uname -s)

#
# Choose what is compiled.  A single G-Known tree can be compiled for multiple
# architectures and with multiple set of compile option.  The following
# names are used to specify the versions to build:
#
#  o dbg - Compile with debugging
#  o opt - Compile with optimization
#  o gprof - Compile for gprof
#
# The variable COMPILE has a space seperated list of which versions should be
# compiled. Modify it to adjust what to compile.  The compile name becomes the
# name of the object directory (e.g. objs/i386/dbg/) and is appended to the
# program names.  Additionally, the optimized program name is linked to the
# program name without extension.  This mechanism is implemented by a
# recursive call to make with OPT variable set to the each value in ${COMPILE}.
# Default value is used by test makes.
#
#
COMPILE=dbg opt
DEFAULT_COMPILE=dbg

ifeq (${OPT},)
    OPT=${DEFAULT_COMPILE}
endif

# Flags and extensions used in file names and directories
# for compiling with different options the same time.

dbg_NAME = dbg
dbg_FLAGS = -g -D DEBUG=1

# Optimized
opt_NAME = opt
opt_FLAGS = -O4 -U DEBUG
# Add -DNDEBUG if you want to live dangerously and leave out all the assertions.

# Gprof enabled.  Might also want -a here
gprof_NAME = gprof
gprof_FLAGS = -O3 -pg -g -DNDEBUG

# Set use G_Known root if not already set
ifeq (${GK_ROOT},)
    GK_ROOT=${ROOT}
endif

# The directory where all of the program binaries will be stored.
ARCH_BINDIR = ${ROOT}/bin/${ARCH}
BINDIR = ${ARCH_BINDIR}/${OPT}

# Architectural specific directory for test programs
ARCH_TEST_BINDIR = objs/${ARCH}
TEST_BINDIR = ${ARCH_TEST_BINDIR}/${OPT}

# The location and name of the libraries.
LIBDIR = ${ROOT}/lib/${ARCH}/${OPT}
GK_LIBDIR = ${GK_ROOT}/lib/${ARCH}/${OPT}

# Libraries and ranlib dependencies
LIBULTIMATE = ${GK_LIBDIR}/libultimate.a
LIBULTIMATE_DEP = ${GK_LIBDIR}/libultimate.ranlib

#LIBMALLOC = ${GK_LIBDIR}/libmalloc.a
#LIBMALLOC_DEP = ${GK_LIBDIR}/libmalloc.ranlib

# Arcitectural specific directory for objects and programs that
# are used internally.
OBJDIR = objs/${ARCH}/${OPT}

# Platform and system specific defines. Get programs from tools directory, if
# available, otherwise use system.
#   CXX - The C++ compiler
#   CC - The C compiler
#   CXXIMPLFLAGS - Flags specific for the implementation of the C++ compiler
#   ZLIBINCL - Include definition for zlib
#   ZLIBLIB - Library definition for zlib
#   MALLOC - We use a different malloc, modified to exit if no memory
#            is available.
#

TOOLSDIR=${GK_ROOT}/tools
LOCAL=/usr/local

CXX = ${TOOLSDIR}/${ARCH}/bin/g++
CC = ${TOOLSDIR}/${ARCH}/bin/gcc
ifeq ($(wildcard ${CXX}),)
    CXX = g++
    CC = gcc
endif

#
# GNU libplot (plotutils package).
#
HAVE_PLOTUTILS=YES
PLOTUTILS_INCL_DIR=${TOOLSDIR}/${ARCH}/include
PLOTUTILS_LIB_DIR=${TOOLSDIR}/${ARCH}/lib

# gcc/g++ specific optimizations
#  - gcc 2.96 on P4:
#    - Many options didn't seem to help maybe hurt a bit.  These
#      appeared to be the best for matrix normaization
#GCCOPTS += -ffast-math -mcpu=pentium -march=pentium

opt_FLAGS +=  ${GCCOPTS}
gprof_FLAGS += ${GCCOPTS}

ZLIBINCL = -I${TOOLSDIR}/share/include
ZLIBLIB = ${TOOLSDIR}/${ARCH}/lib/libz.a
ifeq ($(wildcard ${ZLIBLIB}),)
    ZLIBINCL = -I${LOCAL}/include
    ZLIBLIB = -L${LOCAL}/lib -lz
endif

FIG2DEV = ${TOOLSDIR}/${ARCH}/bin/fig2dev
ifeq ($(wildcard ${FIG2DEV}),)
    FIG2DEV = fig2dev
endif

DOCPP = ${TOOLSDIR}/${ARCH}/bin/doc++
ifeq ($(wildcard ${DOCPP}),)
    DOCPP = doc++
endif

RANLIB = ranlib
ifeq (${ARCH},sun4u)
    RANLIB = true
endif

DOXYGEN = doxygen

#
# We originally use CSRI malloc (shared/malloc) because it was more 
# size efficient than the DEC mallocs.  However GNU malloc works much
# better for the large matrices (maybe using mmap); so we have disabled
# use of CSRI malloc.
# FIXME: remove CSRI malloc from tree???
#
# MALLOC= ${LIBMALLOC}
# System default
MALLOC=

# Mark's memory leak detector:
#  - Make static for better symbols.
#  - Add __USE_MALLOC to have STL use malloc directly rather than its own
#    memory pool.
# 
#MALLOC=-static ${GK_ROOT}/../dbgmalloc/debug-malloc.o
#CXXFLAGS += -D__USE_MALLOC
#MALLOC = -L/usr/local/lib -lefence

PERL=${LOCAL}/bin/perl5
ifeq ($(wildcard ${PERL}),)
    PERL=/usr/bin/perl5
ifeq ($(wildcard ${PERL}),)
    PERL=${LOCAL}/bin/perl
endif
endif

CIMPLFLAGS += -D__USE_FIXED_PROTOTYPES__
CWARNFLAGS += -Wall -W -pedantic -Werror -Wno-sign-compare -Wno-unused-parameter


CXXIMPLFLAGS += -frtti
# CXXWARNFLAGS += -Wall -Werror -Wno-sign-compare
# CXXWARNFLAGS += -Wall -Wno-sign-compare -pedantic
CXXWARNFLAGS +=	-Wall -Woverloaded-virtual -Wsign-promo -Wsynth \
	-Wold-style-cast -W -Wundef  -Wno-unused-parameter
#  -Wfloat-equal -Wundef -Wshadow 


# -fmessage-length=0
ifeq (${ARCH}, alpha)
    CXXMACHFLAGS += -mieee
endif

ifeq (${ARCH}, sun4u)
    CXXMACHFLAGS += -DBYTE_ORDER=LITTLE_ENDIAN
endif

LIBMATH = -lm

# FIXME: wildcard with a variable reference doesn't work in make 3.79.1
#PLOTUTILS_INCL_DIR="/usr/local/include"
#PLOTUTILS_LIB_DIR="/usr/local/lib"
#ifeq ($(wildcard ${PLOTUTILS_INCL_DIR}/plotter.h),)
#    PLOTUTILS_INCL_DIR="/usr/include"
#    PLOTUTILS_LIB_DIR="/usr/lib"
#endif

# Includes, set XTRAINCL to add some new includes
INCL += -I${ROOT}/src -I${GK_ROOT}/src ${ZLIBINCL} ${XTRAINCL}

# Can't use += for CXXFLAGS, because there will already be a setting!
OPT_FLAGS = ${OPT}_FLAGS
CXXFLAGS = ${${OPT_FLAGS}} ${INCL} ${CXXIMPLFLAGS} ${CXXWARNFLAGS} ${CXXMACHFLAGS} ${XTRA_CXXFLAGS}
CFLAGS = ${${OPT_FLAGS}} ${INCL} ${CIMPLFLAGS} ${CWARNFLAGS}

# Other programs used in the build
DEPENDGEN = ${GK_ROOT}/build/dependgen

# Libraries to use for executables.
STDLIBS = ${ZLIBLIB} ${LIBMATH} ${MALLOC}
LIBS = ${LIBULTIMATE} ${STDLIBS}
LIBS_DEP = ${LIBULTIMATE_DEP} ${LIBMALLOC_DEP}

# Local override of variables
ifeq ($(shell test -r $(ROOT)/config.local.mk && echo YES),YES)
    include $(ROOT)/config.local.mk
endif


# CHANGE LOG:
#  3 March 2004 Kevin Karplus
#	Removed -NDEBUG (which turns off assertions) from opt
#  Thu Jan 27 03:15:36 PST 2005 Kevin Karplus
# 	Changed += to = for LIBS and LIBS_DEP
