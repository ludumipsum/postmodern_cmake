include_guard(GLOBAL)

include(pm__core)


# Operating System
if(    "${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    set(PM_OS_WINDOWS TRUE)
elseif("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(PM_OS_LINUX TRUE)
elseif("${CMAKE_SYSTEM_NAME}" MATCHES "Darwin")
    set(PM_OS_OSX TRUE)
else()
    pm_exit(
        "Your operating system ('${CMAKE_SYSTEM_NAME}`) is currently "
        "unsupported by Postmodern CMake. (Read: We've not tried to build on "
        "whatever platform you're on, and assume it'll blow up.)"
    )
endif()

# Architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(PM_64_BIT_ARCH TRUE)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(PM_32_BIT_ARCH TRUE)
else()
    pm_exit(
        "Failed to determine your system's archiecture size. A void pointer is "
        "${CMAKE_SIZEOF_VOID_P} bytes on your system (and we're not sure what "
        "to make of that)."
    )
endif()

# Compiler
if(    "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    set(PM_COMPILER_CLANG TRUE)
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
    set(PM_COMPILER_GNU TRUE)
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "MSVC")
    set(PM_COMPILER_MSVC TRUE)
else()
    pm_exit(
        "Your compiler ('${CMAKE_CXX_COMPILER_ID}`) is currently "
        "unsupported by Postmodern CMake. (Read: We've not tried to build on "
        "whatever compiler you're using, and assume it'll blow up.)"
    )
endif()
