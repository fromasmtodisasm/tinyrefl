include(${TINYREFL_SOURCE_DIR}/cmake/utils.cmake)
include(${TINYREFL_SOURCE_DIR}/cmake/externals.cmake)

set(CPPAST_BUILD_EXAMPLE OFF CACHE BOOL "disable cppast examples")
set(CPPAST_BUILD_TEST OFF CACHE BOOL "disable cppast tests")
set(CPPAST_BUILD_TOOL OFF CACHE BOOL "disable cppast tool")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "build cppfs as static lib")
set(OPTION_BUILD_TESTS OFF CACHE BOOL "disable cppfs tests")
set(SPDLOG_BUILD_EXAMPLES OFF CACHE BOOL "disable spdlog examples")
set(SPDLOG_BUILD_BENCH OFF CACHE BOOL "diable spdlog benchmarks")
set(SPDLOG_BUILD_TESTING OFF CACHE BOOL "disable spdlog unit tests")

if(NOT ("${TINYREFL_LLVM_VERSION}" STREQUAL "${TINYREFL_LLVM_VERSION_MAJOR}.${TINYREFL_LLVM_VERSION_MINOR}.${TINYREFL_LLVM_VERSION_FIX}"))
    message(FATAL_ERROR "LLVM version (${TINYREFL_LLVM_VERSION}) does not match MAJOR.MINOR.FIX (${TINYREFL_LLVM_VERSION_MAJOR}.${TINYREFL_LLVM_VERSION_MINOR}.${TINYREFL_LLVM_VERSION_FIX})")
endif()

if(TINYREFL_USE_LOCAL_LLVM)
    find_program(llvm-config NAMES llvm-config llvm-config-${TINYREFL_LLVM_VERSION_MAJOR}.${TINYREFL_LLVM_VERSION_MINOR})

    if(llvm-config)
        execute_process(COMMAND ${llvm-config} --version
            OUTPUT_VARIABLE llvm-config-version OUTPUT_STRIP_TRAILING_WHITESPACE)

        if(llvm-config-version VERSION_EQUAL TINYREFL_LLVM_VERSION)
            set(LLVM_CONFIG_BINARY "${llvm-config}")
            message(STATUS "Using local LLVM ${TINYREFL_LLVM_VERSION} install")
        else()
            message(FATAL_ERROR "Wrong LLVM install found. Found llvm-config ${llvm-config-version}, required ${TINYREFL_LLVM_VERSION}")
        endif()
    else()
        message(FATAL_ERROR "TINYREFL_USE_LOCAL_LLVM set and llvm-config program not found")
    endif()
else()
    if(NOT TINYREFL_LLVM_DOWNLOAD_URL)
        if(TINYREFL_LLVM_DOWNLOAD_FROM_OFFICIAL_SERVER)
            message(STATUS "Using default LLVM download url from LLVM official servers")

            if(TINYREFL_LLVM_VERSION_MAJOR EQUAL 5)
                set(TINYREFL_LLVM_DOWNLOAD_URL "http://releases.llvm.org/${TINYREFL_LLVM_VERSION}/clang+llvm-${TINYREFL_LLVM_VERSION}-linux-x86_64-ubuntu14.04.tar.xz")
            else()
                set(TINYREFL_LLVM_DOWNLOAD_URL "http://releases.llvm.org/${TINYREFL_LLVM_VERSION}/clang+llvm-${TINYREFL_LLVM_VERSION}-x86_64-linux-gnu-ubuntu-14.04.tar.xz")
            endif()
        else()
            message(STATUS "Using default LLVM download url from bintray")
            set(TINYREFL_LLVM_DOWNLOAD_URL "https://dl.bintray.com/manu343726/llvm-releases/clang+llvm-${TINYREFL_LLVM_VERSION}-x86_64-linux-gnu-ubuntu-14.04.tar.xz")
        endif()
    else()
        message(STATUS "Using custom LLVM download url: ${TINYREFL_LLVM_DOWNLOAD_URL}")
    endif()

    # LLVM releases are compiled with old GCC ABI
    add_definitions(-D_GLIBCXX_USE_CXX11_ABI=0)

    set(LLVM_DOWNLOAD_URL "${TINYREFL_LLVM_DOWNLOAD_URL}")
    message(STATUS "Using LLVM download URL: ${TINYREFL_LLVM_DOWNLOAD_URL}")
endif()


if(NOT TINYREFL_FMT_REPO_URL)
    set(TINYREFL_FMT_REPO_URL https://github.com/fmtlib/fmt.git)
endif()
if(NOT TINYREFL_FMT_VERSION)
    set(TINYREFL_FMT_VERSION 5.1.0)
endif()
if(NOT TINYREFL_CPPAST_REPO_URL)
    set(TINYREFL_CPPAST_REPO_URL https://github.com/Manu343726/cppast.git)
endif()
if(NOT TINYREFL_CPPAST_VERSION)
    set(TINYREFL_CPPAST_VERSION bytech)
endif()
if(NOT TINYREFL_CPPFS_REPO_URL)
    set(TINYREFL_CPPFS_REPO_URL https://github.com/Manu343726/cppfs.git)
endif()
if(NOT TINYREFL_CPPFS_VERSION)
    set(TINYREFL_CPPFS_VERSION optional_libSSL2)
endif()
if(NOT TINYREFL_JINJA2CPP_URL)
    set(TINYREFL_JINJA2CPP_URL https://github.com/flexferrum/jinja2Cpp.git)
endif()
if(NOT TINYREFL_JINJA2CPP_VERSION)
    set(TINYREFL_JINJA2CPP_VERSION bugfix_issue_60)
endif()
if(NOT TINYREFL_SPDLOG_URL)
    set(TINYREFL_SPDLOG_URL "https://github.com/gabime/spdlog")
endif()
if(NOT TINYREFL_SPDLOG_VERSION)
    set(TINYREFL_SPDLOG_VERSION v1.1.0)
endif()
if(NOT TINYREFL_SANITIZERS_CMAKE_URL)
    set(TINYREFL_SANITIZERS_CMAKE_URL "https://github.com/arsenm/sanitizers-cmake")
endif()
if(NOT TINYREFL_SANITIZERS_CMAKE_VERSION)
    set(TINYREFL_SANITIZERS_CMAKE_VERSION aab6948fa863bc1cbe5d0850bc46b9ef02ed4c1a)
endif()

external_dependency(fmt-header-only ${TINYREFL_FMT_REPO_URL} ${TINYREFL_FMT_VERSION})
external_dependency(cppast ${TINYREFL_CPPAST_REPO_URL} ${TINYREFL_CPPAST_VERSION})
external_dependency(cppfs ${TINYREFL_CPPFS_REPO_URL} ${TINYREFL_CPPFS_VERSION})
external_dependency(jinja2cpp ${TINYREFL_JINJA2CPP_URL} ${TINYREFL_JINJA2CPP_VERSION})
external_dependency(spdlog ${TINYREFL_SPDLOG_URL} ${TINYREFL_SPDLOG_VERSION})
external_dependency(sanitizers-cmake ${TINYREFL_SANITIZERS_CMAKE_URL} ${TINYREFL_SANITIZERS_CMAKE_VERSION} NO_CMAKELISTS)
message(STATUS "Sanitizers-cmake source dir: ${sanitizers-cmake_SOURCE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${sanitizers-cmake_SOURCE_DIR}/cmake")

if(NOT LLVM_CONFIG_BINARY)
    message(FATAL_ERROR "llvm-config binary not set")
else()
    message(STATUS "llvm-config binary: ${LLVM_CONFIG_BINARY}")
endif()

execute_process(COMMAND ${LLVM_CONFIG_BINARY} --libdir OUTPUT_VARIABLE stdout)
string(STRIP "${stdout}" stdout)
set(LLVM_CMAKE_PATH "${stdout}/cmake/llvm" CACHE PATH "")
set(CLANG_CMAKE_PATH "${stdout}/cmake/clang" CACHE PATH "")

message(STATUS "llvm cmake path: ${LLVM_CMAKE_PATH}")
message(STATUS "clang cmake path: ${CLANG_CMAKE_PATH}")

function(define_llvm_version_variables TARGET)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION STRING)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION_MAJOR)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION_MINOR)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION_FIX)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION_MAJOR SUFFIX _STRING STRING)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION_MINOR SUFFIX _STRING STRING)
    add_variable_compile_definition(${TARGET} TINYREFL_LLVM_VERSION_FIX SUFFIX _STRING STRING)
endfunction()
