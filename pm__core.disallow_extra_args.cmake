include_guard(GLOBAL)

include(pm__core.msg)
include(pm__core.list_join)


function(pm_disallow_extra_args FN_NAME)
    if(${ARGC} GREATER 1)
        set(argn ${ARGN})
        __pm_list__join(argn ", " EXTRA_ARGS)
        pm_exit("`${FN_NAME}` was passed extra arguments: ${EXTRA_ARGS}")
    endif()
endfunction()
