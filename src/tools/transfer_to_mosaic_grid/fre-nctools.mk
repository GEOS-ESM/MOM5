#
# $Id: fre-nctools.mk,v 20.0 2013/12/14 00:35:45 fms Exp $
# ------------------------------------------------------------------------------
# FMS/FRE Project: Makefile to Build Regridding Executables
# ------------------------------------------------------------------------------
# afy    Ver   1.00  Initial version (Makefile, ver 17.0.4.2)       June 10
# afy    Ver   1.01  Add rules to build MPI-based executable        June 10
# afy    Ver   1.02  Simplified according to fre-nctools standards  June 10
# ------------------------------------------------------------------------------
# Copyright (C) NOAA Geophysical Fluid Dynamics Laboratory, 2009-2010
# Designed and written by V. Balaji, Amy Langenhorst and Aleksey Yakovlev
#
# MPICC and CC are defined in env.$(SITE)
#include ./env.$(SITE)

include $(ESMADIR)/Config/ESMA_base.mk  # Generic stuff
include $(ESMADIR)/Config/ESMA_arch.mk  # System dependencies
include $(ESMADIR)/Config/GMAO_base.mk  # System dependencies
include       ../../../MOM_arch.mk  # arch dependent flags 

MPICC    := mpicc
CC       := icc
CFLAGS   := -O3 -g -traceback
CFLAGS_O2:= -O2 -g -traceback
INCLUDES := -I${INC_NETCDF} -I./ -I../shared -I../../shared/mosaic
CLIBS     := -L${LIB_NETCDF} -L${LIB_HDF5} -lnetcdf -lhdf5_hl -lhdf5 -lz -limf -lsvml $(CLIBS2) $(STATIC)

TARGETS  := transfer_to_mosaic_grid

SOURCES  := transfer_to_mosaic.c
SOURCES  += create_xgrid.c gradient_c2l.c interp.c read_mosaic.c
SOURCES  += mpp_domain.c mpp_io.c tool_util.c

OBJECTS  := $(SOURCES:c=o)

HEADERS = fre-nctools.mk ../shared/mpp.h  ../shared/mpp_domain.h  ../shared/mpp_io.h ../shared/tool_util.h   \
          ../../shared/mosaic/constant.h ../../shared/mosaic/create_xgrid.h  \
          ../../shared/mosaic/gradient_c2l.h ../../shared/mosaic/interp.h  \
          ../../shared/mosaic/mosaic_util.h  ../../shared/mosaic/read_mosaic.h 

all: $(TARGETS)

transfer_to_mosaic_grid: $(OBJECTS) mosaic_util.o mpp.o
	$(MPICC) -o $@ $^ $(CLIBS)

mosaic_util.o: ../../shared/mosaic/mosaic_util.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< 

read_mosaic.o: ../../shared/mosaic/read_mosaic.c $(HEADERS)
	$(CC) -Duse_netCDF $(CFLAGS) $(INCLUDES) -c $< 

gradient_c2l.o: ../../shared/mosaic/gradient_c2l.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< 

interp.o: ../../shared/mosaic/interp.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< 

mpp_io.o: ../shared/mpp_io.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $< 

mpp_domain.o: ../shared/mpp_domain.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $< 

mpp.o: ../shared/mpp.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $< 

tool_util.o: ../shared/tool_util.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $< 

create_xgrid.o: ../../shared/mosaic/create_xgrid.c $(HEADERS)
	$(CC) $(CFLAGS_O2) $(INCLUDES) -c $< 

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $<

clean:
	-rm -f *.o $(TARGETS)
