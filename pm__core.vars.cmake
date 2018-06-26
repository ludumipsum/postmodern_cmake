include_guard(GLOBAL)

include(pm__core.list_join)
include(pm__core.msg)


function(pm_print_var VARn)
    if(DEFINED ${VARn})
        __pm_list__join(${VARn} ", " PRETTY)
        pm_status("${VARn} :: ${PRETTY}")
    else()
        pm_status("${VARn} is not defined!")
    endif()
endfunction()

function(pm_print_is_var_defined VARn)
    if(DEFINED ${VARn})
        pm_status("${VARn} :: is defined")
    else()
        pm_status("${VARn} :: is not defined")
    endif()
endfunction()


function(pm_print_raw_list LISTln)
    # This regex is designed to replace un-escaped semicolons with escaped
    # semicolons, s.t. passing the new string into `pm_status` will result in
    # printed semicolons.
    # Apparently, that means 8 `\`s in the replacement string.
    # Thanks, CMake.
    string(REGEX REPLACE "([^\\]|^);" "\\1\\\\\\\\;" PRETTY "${ARGN}")
    pm_status("${LISTln} :: ${PRETTY}")
endfunction()


function(pm_is_var_set OUTn VARn)
    if(DEFINED ${VARn})
        set(${OUTn} TRUE PARENT_SCOPE)
    else()
        set(${OUTn} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(pm_is_var_unset OUTn VARn)
    if(NOT DEFINED ${VARn})
        set(${OUTn} TRUE PARENT_SCOPE)
    else()
        set(${OUTn} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(pm_is_var_truthy OUTn VARn)
    if(${VARn})
        set(${OUTn} TRUE PARENT_SCOPE)
    else()
        set(${OUTn} FALSE PARENT_SCOPE)
    endif()
endfunction()

function(pm_is_var_falsy OUTn VARn)
    if(NOT ${VARn})
        set(${OUTn} TRUE PARENT_SCOPE)
    else()
        set(${OUTn} FALSE PARENT_SCOPE)
    endif()
endfunction()


function(pm_set_if_unset VARn VAL)
    if(NOT DEFINED ${VARn})
        set(${VARn} ${VAL} PARENT_SCOPE)
    endif()
endfunction()

function(pm_set_if_falsy VARn VAL)
    if(NOT ${VARn})
        set(${VARn} ${VAL} PARENT_SCOPE)
    endif()
endfunction()
