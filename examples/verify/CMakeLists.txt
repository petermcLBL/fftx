##
## Copyright (c) 2018-2021, Carnegie Mellon University
## All rights reserved.
##
## See LICENSE file for full information
##

include ( ../ExamplesCommon.cmake )

cmake_minimum_required ( VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION} )

##  ===== For most examples you should not need to modify anything ABOVE this line =====

##  Set the project name.  Preferred name is just the *name* of the example folder 
project ( verify ${_lang_add} ${_lang_base} )

##  File naming convention is: <prefix>.<stem>.xxxxx; set _stem and _prefix(es)
##  Test program name is:  test<project name>.{cpp|cu}

set ( _stem fftx )
set ( _prefixes mddft3 imddft3 prdft3 iprdft3 )
set ( BUILD_PROGRAM test${PROJECT_NAME} )

set ( _prefixes_device )
set ( BUILD_PROGRAM_DEVICE test${PROJECT_NAME}_device )

if ( ${USE_FFTW3} )
    set ( _prefixes_fftw )
    set ( BUILD_PROGRAM_FFTW test${PROJECT_NAME}_fftw )
endif ()

if ( ${USE_MKL} )
    # find_package(MKL CONFIG REQUIRED)
    message(STATUS "${MKL_IMPORTED_TARGETS}") #Provides available list of targets based on input
    set ( _prefixes_mkl )
    set ( BUILD_PROGRAM_MKL test${PROJECT_NAME}_mkl )
    # list ( APPEND ADDL_COMPILE_FLAGS -mkl="sequential" )
endif ()

##  ===== For most examples you should not need to modify anything BELOW this line =====

manage_deps_codegen ( ${_codegen} ${_stem} "${_prefixes}" )
add_includes_libs_to_target ( ${BUILD_PROGRAM} ${_stem} "${_prefixes}" )
add_includes_libs_to_target ( ${BUILD_PROGRAM_DEVICE} ${_stem} "${_prefixes_device}" )
if ( ${USE_FFTW3} )
    add_includes_libs_to_target ( ${BUILD_PROGRAM_FFTW} ${_stem} "${_prefixes_fftw}" )
endif ()
if ( ${USE_MKL} )
    add_includes_libs_to_target ( ${BUILD_PROGRAM_MKL} ${_stem} "${_prefixes_mkl}" )
endif ()

## Now for the version with _lib suffix.

set ( BUILD_PROG_LIB test${PROJECT_NAME}_lib )
set ( _prefixes_lib )

##  message ( STATUS "${BUILD_PROG_LIB}: Library include dirs = ${_library_includes}" )
##  message ( STATUS "${BUILD_PROG_LIB}: Library names = ${_library_names}" )

manage_deps_codegen ( ${_codegen} ${_stem} "${_prefixes_lib}" )
add_includes_libs_to_target ( ${BUILD_PROG_LIB} ${_stem} "${_prefixes_lib}" )
