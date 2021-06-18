##
## Copyright (c) 2018-2021, Carnegie Mellon University
## All rights reserved.
##
## See LICENSE file for full information
##

##  create and run a driver program, given a <prefix> and a <stem> (filename =
##  <prefix>.<stem>.cpp; driver = <prefix>.<stem>.driver[.exe]).  If an
##  additional argument (beyond the named arguments) is given it is treated as a
##  list of additional include directories, if required.
##  Outputs from running the driver program are: <prefix>.<stem>.plan.g and
##  <prefix>.<stem>.codegen.hpp
##
##  For example:
##      run_driver_program ( "mddft" "fftx" "/path/to/addl/includes" )
##  will compile source file mddft.fftx.cpp to program mddft.fftx.driver[.exe]
##  then run it to create mddft.fftx.plan.g and mddft.fftx.codegen.hpp, adding
##  "/path/to/addl/includes" to the search path for include files.

function ( run_driver_program prefix stem )
    message ( "build and run driver for ${prefix}.${stem}.cpp" )
    set     ( _driver ${PROJECT_NAME}.${prefix}.${stem}.driver )
    set     ( ${prefix}_driver ${prefix}.${stem}.driver PARENT_SCOPE )
    add_executable ( ${_driver} ${prefix}.${stem}.cpp )
    target_compile_options ( ${_driver} PRIVATE ${ADDL_COMPILE_FLAGS} )
    set_property ( TARGET ${_driver} PROPERTY CXX_STANDARD 11 )
    message ( STATUS "Added ${ADDL_COMPILE_FLAGS} to target: ${_driver}" )

    if ( ${ARGC} GREATER 2 )
	##  received optional include directories -- add to target
	foreach ( _fil ${ARGN} )
	    message ( "add ${_fil} to include directories for ${_driver}" )
	    target_include_directories ( ${_driver} PRIVATE ${_fil} )
	endforeach ()
    endif ()
    
    ##  Run the driver program to create ~.codegen.hpp and ~.plan.g

    set ( _plan ${prefix}.${stem}.plan.g )
    set ( ${prefix}_plan ${prefix}.${stem}.plan.g PARENT_SCOPE )
    set ( _header ${prefix}.${stem}.codegen.hpp )
    ##  message ( "define vars: plan = ${_plan}, header = ${_header}" )
    
    if ( WIN32 )
	add_custom_command ( OUTPUT ${_plan} ${_header} 
	COMMAND IF EXIST ${_plan} ( DEL /F ${_plan} )
	COMMAND IF EXIST ${_header} ( DEL /F ${_header} )
	COMMAND ${_driver} ${prefix} > ${_plan}
	DEPENDS ${_driver}
	VERBATIM
	COMMENT "Generating ${_plan}" )
    else ()
	include ( FindUnixCommands )
	add_custom_command ( OUTPUT ${_plan} ${_header}
	    COMMAND ${BASH} -c "rm -f ${_plan} ${_header} ; ${CMAKE_CURRENT_BINARY_DIR}/${_driver} ${prefix} > ${_plan}"
	    DEPENDS ${_driver}
	    VERBATIM
	    COMMENT "Generating ${_plan}" )
    endif ()

    add_custom_target ( NAME.${PROJECT_NAME}.${_plan} ALL
	DEPENDS ${_driver}
	VERBATIM )
    
endfunction ()


##  create a generator script, given a <prefix> and a <stem> (script =
##  <prefix>.<stem>.generator.g.  This function assumes the plan.g file has
##  already been created (e.g., by calling run_driver_program() which creates
##  the plan and codegen header files).  For example:
##      create_generator_file ( _codefor "mddft" "fftx" )
##  will create script mddft.fftx.generator.g, _codefor indicates if code should
##  be generated for CPU or GPU.  This script may be consumed in a subsequent
##  step to create a source code file (e.g., see RunSpiral.cmake).
##  Additionally, the variable ${mddft_gen} = "mddft.fftx.generator.g" is
##  defined.
    
##  define standard files... (may need to customize this later)

set ( BACKEND_SPIRAL_CPU_DIR      ${BACKEND_SOURCE_DIR}/spiral_cpu_serial )
set ( BACKEND_SPIRAL_GPU_DIR      ${BACKEND_SOURCE_DIR}/spiral_gpu )
set ( BACKEND_SPIRAL_HIP_DIR      ${BACKEND_SOURCE_DIR}/spiral_hip )

set ( SPIRAL_BACKEND_CPU_PREAMBLE ${BACKEND_SPIRAL_CPU_DIR}/preamble.g )
set ( SPIRAL_BACKEND_GPU_PREAMBLE ${BACKEND_SPIRAL_GPU_DIR}/preamble.g )
set ( SPIRAL_BACKEND_HIP_PREAMBLE ${BACKEND_SPIRAL_HIP_DIR}/preamble.g )
set ( SPIRAL_BACKEND_CPU_CODEGEN  ${BACKEND_SPIRAL_CPU_DIR}/codegen.g  )
set ( SPIRAL_BACKEND_GPU_CODEGEN  ${BACKEND_SPIRAL_GPU_DIR}/codegen.g  )
set ( SPIRAL_BACKEND_HIP_CODEGEN  ${BACKEND_SPIRAL_HIP_DIR}/codegen.g  )

function ( create_generator_file _codefor prefix stem )
    message ( "create generator SPIRAL script ${prefix}.${stem}.generator.g" )
    set     ( ${prefix}_gen ${prefix}.${stem}.generator.g PARENT_SCOPE )
    set     ( _gen ${prefix}.${stem}.generator.g )
    set     ( _plan   ${prefix}.${stem}.plan.g )

    set ( _preamble ${SPIRAL_BACKEND_${_codefor}_PREAMBLE} )
    set ( _postfix  ${SPIRAL_BACKEND_${_codefor}_CODEGEN} )
    if ( "X${_generator_script}" STREQUAL "X" )
	##  The complete script is not defined -- bo action required
    elseif ( ${_generator_script} STREQUAL "COMPLETE" )
	##  Don't add preamble and codegen pieces
	set ( _preamble )
	set ( _postfix  )
    endif ()

    if ( WIN32 )
	add_custom_command ( OUTPUT ${_gen}
	    COMMAND ${Python3_EXECUTABLE} ${SPIRAL_SOURCE_DIR}/gap/bin/catfiles.py
	            ${_gen} ${_preamble} ${_plan} ${_postfix}
            DEPENDS ${_plan}
	    VERBATIM
	    COMMENT "Generating ${_gen}" )
    else ()
	include ( FindUnixCommands )
	add_custom_command ( OUTPUT ${_gen}
	    COMMAND ${Python3_EXECUTABLE} ${SPIRAL_SOURCE_DIR}/gap/bin/catfiles.py
	            ${_gen} ${_preamble} ${_plan} ${_postfix}
	    DEPENDS ${_plan}
	    VERBATIM
	    COMMENT "Generating ${_gen}" )
    endif ()

    add_custom_target ( NAME.${PROJECT_NAME}.${_gen} ALL
	DEPENDS ${_plan}
	VERBATIM )

endfunction ()


##  run_hipify_perl() is a simple function called to run hipify-perl on a CUDA
##  source code file.  The two arguments are the file name root (_program) and
##  suffix (_suffix).  The resulting converted file will be written to
##  ${_program}-hip.${_suffix}.

function ( run_hipify_perl _program _suffix )
    if ( WIN32 )
	## TBD
    else ()
	include ( FindUnixCommands )
	add_custom_command ( OUTPUT ${_program}-hip.${_suffix}
	    COMMAND ${BASH} -c "rm -f ${_program}-hip.${_suffix} && hipify-perl ${CMAKE_CURRENT_SOURCE_DIR}/${_program}.${_suffix} > ${_program}-hip.${_suffix}"
	    DEPENDS ${_program}.${_suffix}
	    VERBATIM
	    COMMENT "Generating ${_program}-hip.${_suffix}" )
    endif ()

endfunction ()


##  add_includes_libs_to_target() is a function called to add include
##  directories, library paths, and libraries to an executable target.  Its
##  purpose is to encapsulate all the information in one place and let each
##  example cmake simply call this to get the appropriate qualifier for each
##  build.

function ( add_includes_libs_to_target _target _stem _prefixes )
    ##  Test _codegen and setup accordingly
    if ( ${_codegen} STREQUAL "HIP" )
	## run hipify-perl on the test driver
	run_hipify_perl ( ${_target} ${_suffix} )
	list ( APPEND _all_build_srcs ${_target}-hip.${_suffix} )
	set_source_files_properties ( ${_target}-hip.${_suffix} PROPERTIES LANGUAGE CXX )
	foreach ( _pref ${_prefixes} )
	    set_source_files_properties ( ${_pref}.${_stem}.source.${_suffix} PROPERTIES LANGUAGE CXX )
	endforeach ()
    else ()
	list ( APPEND _all_build_srcs ${_target}.${_suffix} )
    endif ()

    add_executable   ( ${_target} ${_all_build_srcs} )
    add_dependencies ( ${_target} ${_all_build_deps} )
 
    target_compile_options ( ${_target} PRIVATE ${ADDL_COMPILE_FLAGS} )
 
    target_include_directories ( ${_target} PRIVATE
	${${PROJECT_NAME}_BINARY_DIR} ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR} )

    if ( ${_codegen} STREQUAL "HIP" )
	target_link_directories    ( ${_target} PRIVATE $ENV{ROCM_PATH}/lib )
	target_link_libraries      ( ${_target} ${LIBS_FOR_HIP} )
    elseif ( ${_codegen} STREQUAL "GPU" )
	target_link_libraries      ( ${_target} ${LIBS_FOR_CUDA} )
    endif ()

    set ( INSTALL_DIR_TARGET ${CMAKE_BINARY_DIR}/bin )
    install ( TARGETS ${_target} DESTINATION ${INSTALL_DIR_TARGET} )

endfunction ()
    

##  manage_deps_codegen() is a function called to orchestrate creating the
##  intermediate files (targets) for codegen and build the list of dependencies
##  for a test program.  The following conventions are assumed:
##  File naming convention is: <prefix>.<stem>.xxxxx (e.g., <prefix>.<stem>.cpp)
##  The function is passed a codegen flag (create CPU/GPU/HIP code), a stem, a list
##  of prefixes (1 or more) and builds lists of all source code files for the
##  test program and a list of dependency names (to ensure cmake builds all
##  targets in the right order).
##

function ( manage_deps_codegen _codefor _stem _prefixes )
    message ( "manage_deps_codegen: # args = ${ARGC}, code for = ${_codefor}, stem = ${_stem}, prefixes = ${_prefixes}" )
    if ( ${ARGC} LESS 3 )
	message ( FATAL_ERROR "manage_deps_codegen() requires at least 1 prefix" )
    endif ()
    
    if ( ( ${_codefor} STREQUAL "GPU" ) OR ( ${_codefor} STREQUAL "HIP" ) )
	set ( _suffix cu PARENT_SCOPE )
	set ( _suffix cu )
    else ()
	set ( _suffix cpp PARENT_SCOPE )
	set ( _suffix cpp )
    endif ()
       
    foreach ( _prefix ${_prefixes} ) 
	run_driver_program ( ${_prefix} ${_stem} )
	set ( _driver ${PROJECT_NAME}.${${_prefix}_driver} )
	set ( _plan ${${_prefix}_plan} )
	set ( _hdr  ${_prefix}.${_stem}.codegen.hpp )

	##  Create the generator scripts: ~.generator.g files

	create_generator_file ( ${_codefor} ${_prefix} ${_stem} )
	set ( _gen ${${_prefix}_gen} )

	##  Create the C source code from the SPIRAL generator script(s)

	set                ( _ccode ${_prefix}.${_stem}.source.${_suffix} )
	file               ( TO_NATIVE_PATH ${${PROJECT_NAME}_BINARY_DIR}/${_gen} _gfile )
	create_source_file ( ${_gfile} ${_ccode} )

	##  append to our running lists
	list ( APPEND _all_build_srcs ${_hdr} ${_ccode} )
	list ( APPEND _all_build_deps ${_driver}
               NAME.${PROJECT_NAME}.${_plan}
               NAME.${PROJECT_NAME}.${_gen}
               NAME.${PROJECT_NAME}.${_ccode} )

    endforeach ()

    set ( _all_build_srcs ${_all_build_srcs} PARENT_SCOPE )
    set ( _all_build_deps ${_all_build_deps} PARENT_SCOPE )

endfunction ()


##  manage_add_subdir() is a function to add a subdirectory to the list of
##  examples invoked.  It requires three arguments: subdirectory, buildForCPU,
##  buildForGpu; where subdirectory is the name of the subdirectory containing
##  the example, buildForCpu and buildForGpu are logical (True or False) values
##  indicating if the example should be built.
##  NOTE: If buildForGpu is specified a CUDA (Nvidia) or Hip/rocm (AMD) toolkit is required.

function ( manage_add_subdir _subdir _buildForCpu _buildForGpu )

    if ( ${_buildForCpu} AND ${_codegen} STREQUAL "CPU" )
	message ( STATUS "Adding subdirectory ${_subdir} to build for ${_codegen}" )
	add_subdirectory ( ${_subdir} )
    elseif ( NOT ${_buildForCpu} AND ${_codegen} STREQUAL "CPU" )
	message ( STATUS "Do NOT build subdirectory ${_subdir} for ${_codegen}" )
    endif ()

    if ( ${_buildForGpu} AND ( ${_codegen} STREQUAL "GPU"  OR ${_codegen} STREQUAL "HIP" ) )
	message ( STATUS "Adding subdirectory ${_subdir} to build for ${_codegen}" )
	add_subdirectory ( ${_subdir} )
    elseif ( NOT ${_buildForGpu} AND ( ${_codegen} STREQUAL "GPU"  OR ${_codegen} STREQUAL "HIP" ) )
	message ( STATUS "Do NOT build subdirectory ${_subdir} for ${_codegen}" )
    endif ()

endfunction ()

