# Simple cmake script which may be used to build
# cmake from automatically downloaded source
#
#   cd tmp/
#   cmake -P CMake-autobuild-v2.cmake
# you should end up with a
#   tmp/cmake-x.y.z source tree
#   tmp/cmake-x.y.z-build build tree
# configure and compiled tree, using the tarball found on Kitware.
#
# if you access the internet through a proxy then you should
# set the "http_proxy" and "https_proxy" environment variable
# to apppropriate value before running the CMake script.
#  e.g.:
#     export http_proxy=http://myproxy.mydomain.fr:80
#     export https_proxy=https://myproxy.mydomain.fr:80


cmake_minimum_required(VERSION 3.0)
set(CMAKE_VERSION "3.6.2")
set(CMAKE_FILE_PREFIX "cmake-${CMAKE_VERSION}")
string(REGEX MATCH "[0-9]\\.[0-9]" CMAKE_MAJOR "${CMAKE_VERSION}")
set(CMAKE_REMOTE_PREFIX "http://www.cmake.org/files/v${CMAKE_MAJOR}/")
set(CMAKE_FILE_SUFFIX ".tar.gz")
set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_BUILD_QTDIALOG "ON")
set(CMAKE_BUILD_GENERATOR "")
#try Ninja (https://ninja-build.org) if you have it installed
#set(CMAKE_BUILD_GENERATOR "-GNinja")
set(CPACK_GEN "TGZ")
#try another CPack generator
set(CPACK_GEN "RPM")

set(LOCAL_FILE "./${CMAKE_FILE_PREFIX}${CMAKE_FILE_SUFFIX}")
set(REMOTE_FILE "${CMAKE_REMOTE_PREFIX}${CMAKE_FILE_PREFIX}${CMAKE_FILE_SUFFIX}")

message(STATUS "Trying to autoinstall CMake version ${CMAKE_VERSION} using ${REMOTE_FILE} file...")

message(STATUS "Downloading...")
if (EXISTS ${LOCAL_FILE})
   message(STATUS "Already there: nothing to do")
else (EXISTS ${LOCAL_FILE})
   message(STATUS "Not there, trying to download...")
   file(DOWNLOAD ${REMOTE_FILE} ${LOCAL_FILE}
        TIMEOUT 600
        STATUS DL_STATUS
        LOG DL_LOG
        SHOW_PROGRESS)
   list(GET DL_STATUS 0 DL_NOK)
   if ("${DL_LOG}" MATCHES "404 Not Found")
      set(DL_NOK 1)
   endif ("${DL_LOG}" MATCHES "404 Not Found")
   if (DL_NOK)
      # we shall remove the file because it is created
      # with an inappropriate content
      file(REMOVE ${LOCAL_FILE})
      message(SEND_ERROR "Download failed: ${DL_LOG}")
   else (DL_NOK)
      message(STATUS "Download successful.")
   endif (DL_NOK)
endif (EXISTS ${LOCAL_FILE})

message(STATUS "Unarchiving the file")
execute_process(COMMAND ${CMAKE_COMMAND} -E tar zxvf ${LOCAL_FILE}
                RESULT_VARIABLE UNTAR_RES
                OUTPUT_VARIABLE UNTAR_OUT
                ERROR_VARIABLE UNTAR_ERR
                )
message(STATUS "CMake version ${CMAKE_VERSION} has been unarchived in ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_FILE_PREFIX}.")

message(STATUS "Configuring with CMake (build type=${CMAKE_BUILD_TYPE}, QtDialog=${CMAKE_BUILD_QTDIALOG}, build generator=${CMAKE_BUILD_GENERATOR})...")
file(MAKE_DIRECTORY ${CMAKE_FILE_PREFIX}-build)
execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_BUILD_GENERATOR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_QtDialog:BOOL=${CMAKE_BUILD_QTDIALOG} ../${CMAKE_FILE_PREFIX}
                WORKING_DIRECTORY ${CMAKE_FILE_PREFIX}-build
                RESULT_VARIABLE CONFIG_RES
                OUTPUT_VARIABLE CONFIG_OUT
                ERROR_VARIABLE CONFIG_ERR
                TIMEOUT 200
                )
if (CONFIG_RES)
   message(ERROR "Configuration failed: ${CONFIG_OUT} / ${CONFIG_ERR}")
endif()

message(STATUS "Building with cmake --build ...")
execute_process(COMMAND ${CMAKE_COMMAND} --build .
                WORKING_DIRECTORY ${CMAKE_FILE_PREFIX}-build
                RESULT_VARIABLE CONFIG_RES
                OUTPUT_VARIABLE CONFIG_OUT
                ERROR_VARIABLE CONFIG_ERR
                ) 

message(STATUS "Create package ${CPACK_GEN} with CPack...")
execute_process(COMMAND ${CMAKE_CPACK_COMMAND} -G ${CPACK_GEN}
                WORKING_DIRECTORY ${CMAKE_FILE_PREFIX}-build
                RESULT_VARIABLE CONFIG_RES
                OUTPUT_VARIABLE CONFIG_OUT
                ERROR_VARIABLE CONFIG_ERR
                )
message(STATUS "CMake version ${CMAKE_VERSION} has been built in ${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_FILE_PREFIX}.")
string(REGEX MATCH "CPack: - package:(.*)generated" PACKAGES "${CONFIG_OUT}")
message(STATUS "CMake package(s) are: ${CMAKE_MATCH_1}")
