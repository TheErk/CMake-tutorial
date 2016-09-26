cmake_minimum_required (VERSION 3.0)
# This project use C source code
project (TotallyFree C)
# require specific language standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_EXTENSIONS False)

set(TotallyFree_VERSION_MAJOR 1)
set(TotallyFree_VERSION_MINOR 0)
# Build option with default value to ON
option(WITH_ACRODICT "Include acronym dictionary support" ON)
if(NOT WIN32)
  option(WITH_GUESS_NAME "Guess acronym name" ON)
endif(NOT WIN32)
set(BUILD_SHARED_LIBS true)

option(STATIC_BUILD "Build static executable" OFF)
if(STATIC_BUILD)
  set(BUILD_SHARED_LIBS false)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
  set(CMAKE_EXE_LINKER_FLAGS "-static")
endif()
# build executable using specified list of source files
add_executable(Acrolibre acrolibre.c)
install(TARGETS Acrolibre DESTINATION bin)
if (WITH_ACRODICT)
   # list of sources in our library
   set(LIBSRC acrodict.h acrodict.c)
   if (WITH_GUESS_NAME)
     set_source_files_properties(acrodict.c PROPERTIES COMPILE_FLAGS "-DGUESS_NAME")
   endif(WITH_GUESS_NAME)
   add_library(acrodict ${LIBSRC})
   # Build Acrolibre with dictionary support
   add_executable(Acrodictlibre acrolibre.c)
   target_link_libraries(Acrodictlibre acrodict)
   set_target_properties(Acrodictlibre PROPERTIES COMPILE_FLAGS "-DUSE_ACRODICT")

   install(TARGETS Acrodictlibre acrodict
           RUNTIME DESTINATION bin
           LIBRARY DESTINATION lib
           ARCHIVE DESTINATION lib/static)
   install(FILES acrodict.h DESTINATION include)
endif(WITH_ACRODICT)

enable_testing()
add_test(toulibre-builtin
         Acrolibre "toulibre")
add_test(toulibre-dict
         Acrodictlibre "toulibre")
add_test(FLOSS-dict
         Acrodictlibre "FLOSS")
add_test(FLOSS-fail
         Acrolibre "FLOSS")
#set_tests_properties (FLOSS-fail
#  PROPERTIES
#  PASS_REGULAR_EXPRESSION "Sorry, I don't know:.*FLOSS")

set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_VERSION_MAJOR 1)
set(CPACK_PACKAGE_VERSION_MINOR 1)
set(CPACK_PACKAGE_VERSION_PATCH 0)
include(CPack)
