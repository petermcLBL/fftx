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

##  prefixes are only required for test${PROJECT_NAME}

set ( BUILD_PROGS test${PROJECT_NAME} )

list ( APPEND BUILD_PROGS test${PROJECT_NAME}_lib )

##  test of cuFFT or rocFFT library
if ( ( ${_codegen} STREQUAL "CUDA" ) OR ( ${_codegen} STREQUAL "HIP" ) )
    list ( APPEND BUILD_PROGS test${PROJECT_NAME}_device )
endif ()

if ( ${USE_FFTW3} )
    list ( APPEND BUILD_PROGS test${PROJECT_NAME}_fftw )
endif ()

if ( ${USE_MKL} )
    list ( APPEND BUILD_PROGS test${PROJECT_NAME}_mkl )
#    # find_package(MKL CONFIG REQUIRED)
#    message(STATUS "${MKL_IMPORTED_TARGETS}") #Provides available list of targets based on input
#    set ( _prefixes_mkl )
#    set ( BUILD_PROGRAM_MKL test${PROJECT_NAME}_mkl )
#    # list ( APPEND ADDL_COMPILE_FLAGS -mkl="sequential" )
endif ()

##  One .cpp file is coded with device_macros and should build for CUDA & HIP
set ( _desired_suffix cpp )

##  ===== For most examples you should not need to modify anything BELOW this line =====

##  Build the executables *with no prefix dependencies* first (because the list of dependencies is cumulative)

foreach ( _prog ${BUILD_PROGS} )
    ##  Build the dependencies and get the include directories / libraries for each program
    if ( ${_codegen} STREQUAL "HIP" )
	set_source_files_properties ( ${_prog}.${_desired_suffix} PROPERTIES LANGUAGE CXX )
    elseif ( ${_codegen} STREQUAL "CUDA" )
	set_source_files_properties ( ${_prog}.${_desired_suffix} PROPERTIES LANGUAGE CUDA )
    endif ()

    if ( ${_prog} STREQUAL "test${PROJECT_NAME}" )
	set ( _pref ${_prefixes} )
    else ()
	set ( _pref )
    endif ()

    manage_deps_codegen ( ${_codegen} ${_stem} "${_pref}" )
    add_includes_libs_to_target ( ${_prog} ${_stem} "${_pref}" )
endforeach ()
