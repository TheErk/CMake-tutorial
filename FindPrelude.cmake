# - Find Prelude compiler
# Find the Prelude synchronous language compiler with associated includes path.
# See http://www.lifl.fr/~forget/prelude.html
# and https://forge.onera.fr/projects/prelude
# This module defines
#  PRELUDE_COMPILER, the prelude compiler
#  PRELUDE_COMPILER_VERSION, the version of the prelude compiler
#  PRELUDE_INCLUDE_DIR, where to find dword.h, etc.
#  PRELUDE_FOUND, If false, Prelude was not found.
# On can set PRELUDE_PATH_HINT before using find_package(Prelude) and the
# module with use the PATH as a hint to find preludec.
#
# The hint can be given on the command line too:
#   cmake -DPRELUDE_PATH_HINT=/DATA/ERIC/Prelude/prelude-x.y /path/to/source
#
# The module defines some functions:
#   Prelude_Compile(NODE <Prelude Main Node>
#                   PLU_FILES <Prelude files>
#                  [USER_C_FILES <C files>]
#                  [NOENCODING]
#                  [REAL_IS_DOUBLE]
#                  [BOOL_IS_STDBOOL]
#                  [TRACING fmt])
#

if(PRELUDE_PATH_HINT)
  message(STATUS "FindPrelude: using PATH HINT: ${PRELUDE_PATH_HINT}")
else()
  set(PRELUDE_PATH_HINT)
endif()

#One can add his/her own builtin PATH.
#FILE(TO_CMAKE_PATH "/DATA/ERIC/Prelude/prelude-x.y" MYPATH)
#list(APPEND PRELUDE_PATH_HINT ${MYPATH})

# FIND_PROGRAM twice using NO_DEFAULT_PATH on first shot
find_program(PRELUDE_COMPILER
  NAMES preludec
  PATHS ${PRELUDE_PATH_HINT}
  PATH_SUFFIXES bin
  NO_DEFAULT_PATH
  DOC "Path to the Prelude compiler command 'preludec'")

find_program(PRELUDE_COMPILER
  NAMES preludec
  PATHS ${PRELUDE_PATH_HINT}
  PATH_SUFFIXES bin
  DOC "Path to the Prelude compiler command 'preludec'")

if(PRELUDE_COMPILER)
    # get the path where the prelude compiler was found
    get_filename_component(PRELUDE_PATH ${PRELUDE_COMPILER} PATH)
    # remove bin
    get_filename_component(PRELUDE_PATH ${PRELUDE_PATH} PATH)
    # add path to PRELUDE_PATH_HINT
    list(APPEND PRELUDE_PATH_HINT ${PRELUDE_PATH})
    execute_process(COMMAND ${PRELUDE_COMPILER} -version
        OUTPUT_VARIABLE PRELUDE_COMPILER_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    message(STATUS "Prelude compiler version is : ${PRELUDE_COMPILER_VERSION}")
    execute_process(COMMAND ${PRELUDE_COMPILER} -help
        OUTPUT_VARIABLE PRELUDE_OPTIONS_LIST
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(PRELUDE_TRACING_OPTION)
    string(REGEX MATCH "-tracing output" PRELUDE_TRACING_OPTION "${PRELUDE_OPTIONS_LIST}")
    if (PRELUDE_TRACING_OPTION)
      message(STATUS "Prelude compiler support -tracing.")
      set(PRELUDE_SUPPORT_TRACING "YES")
    else(PRELUDE_TRACING_OPTION)
      message(STATUS "Prelude compiler DOES NOT support -tracing.")
      set(PRELUDE_SUPPORT_TRACING "NO")
    endif(PRELUDE_TRACING_OPTION)
endif(PRELUDE_COMPILER)

find_path(PRELUDE_INCLUDE_DIR
          NAMES dword.h
          PATHS ${PRELUDE_PATH_HINT}
          PATH_SUFFIXES lib/prelude
          DOC "The Prelude include headers")

# Check if LTTng is to be supported
if (NOT LTTNG_FOUND)
  option(ENABLE_LTTNG_SUPPORT "Enable LTTng support" OFF)
  if(ENABLE_LTTNG_SUPPORT)
    find_package(LTTng)
    if (LTTNG_FOUND)
      message(STATUS "Will build LTTng support into library...")
      include_directories(${LTTNG_INCLUDE_DIR})
    endif(LTTNG_FOUND)
  endif(ENABLE_LTTNG_SUPPORT)
endif()

# Macros used to compile a prelude library
include(CMakeParseArguments)
function(Prelude_Compile)
  set(options NOENCODING REAL_IS_DOUBLE BOOL_IS_STDBOOL)
  set(oneValueArgs NODE TRACING)
  set(multiValueArgs PLU_FILES USER_C_FILES)
  cmake_parse_arguments(PLU "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(PLU_NOENCODING)
    set(PRELUDE_ENCODING "-no_encoding")
    set(PRELUDE_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${PLU_NODE}/noencoding")
    set(PRELUDE_ENCODING_SUFFIX "-noencoding")
  else()
    set(PRELUDE_ENCODING)
    set(PRELUDE_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${PLU_NODE}/encoded")
    set(PRELUDE_ENCODING_SUFFIX "-encoded")
  endif()

  if(PLU_REAL_IS_DOUBLE)
    set(PRELUDE_REAL_OPT "-real_is_double")
  else()
    set(PRELUDE_REAL_OPT "")
  endif()

  if(PLU_BOOL_IS_STDBOOL)
    set(PRELUDE_BOOL_OPT "-bool_is_stdbool")
  else()
    set(PRELUDE_BOOL_OPT "")
  endif()

  if (PRELUDE_SUPPORT_TRACING)
    if(PLU_TRACING)
      set(PRELUDE_TRACING_OPT "-tracing")
      set(PRELUDE_TRACING_OPT_VALUE "${PLU_TRACING}")
    else()
      set(PRELUDE_TRACING_OPT "-tracing")
      set(PRELUDE_TRACING_OPT_VALUE "no")
    endif()
  else(PRELUDE_SUPPORT_TRACING)
    set(PRELUDE_TRACING_OPT "")
    set(PRELUDE_TRACING_OPT_VALUE "")
  endif(PRELUDE_SUPPORT_TRACING)

  file(MAKE_DIRECTORY ${PRELUDE_OUTPUT_DIR})
  set(PRELUDE_GENERATED_FILES
      ${PRELUDE_OUTPUT_DIR}/${PLU_NODE}.c
      ${PRELUDE_OUTPUT_DIR}/${PLU_NODE}.h)

  add_custom_command(
      OUTPUT ${PRELUDE_GENERATED_FILES}
      COMMAND ${PRELUDE_COMPILER} ${PRELUDE_ENCODING} ${PRELUDE_BOOL_OPT} ${PRELUDE_REAL_OPT} ${PRELUDE_TRACING_OPT} ${PRELUDE_TRACING_OPT_VALUE} -d ${PRELUDE_OUTPUT_DIR} -node ${PLU_NODE} ${PLU_PLU_FILES}
      DEPENDS ${PLU_PLU_FILES}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "Compile prelude source(s): ${PLU_PLU_FILES})"
  )
  set_source_files_properties(${PRELUDE_GENERATED_FILES}
                              PROPERTIES GENERATED TRUE)
  include_directories(${PRELUDE_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR} ${PRELUDE_OUTPUT_DIR})
  add_library(${PLU_NODE}${PRELUDE_ENCODING_SUFFIX} SHARED
              ${PRELUDE_GENERATED_FILES} ${PLU_USER_C_FILES}
	          )
  if(LTTNG_FOUND)
    target_link_libraries(${PLU_NODE}${PRELUDE_ENCODING_SUFFIX} ${LTTNG_LIBRARIES})
  endif()
  message(STATUS "Prelude: Added rule for building prelude library: ${PLU_NODE}")
endfunction(Prelude_Compile)

# handle the QUIETLY and REQUIRED arguments and set PRELUDE_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PRELUDE 
                                  REQUIRED_VARS PRELUDE_COMPILER PRELUDE_INCLUDE_DIR)
# VERSION FPHSA options not handled by CMake version < 2.8.2)
#                                  VERSION_VAR PRELUDE_COMPILER_VERSION)
mark_as_advanced(PRELUDE_INCLUDE_DIR)
