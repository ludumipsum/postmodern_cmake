include_guard(GLOBAL)


include(pm__core.list_join)

function(pm_status)
    set(MSGl ${ARGN})
    __pm_list__join(MSGl "" MSG)
    message(STATUS "${MSG}")
endfunction()

function(pm_warn)
    set(MSGl ${ARGN})
    __pm_list__join(MSGl "" MSG)
    message(WARNING
        "-- warn\n"
        "${MSG}\n")
endfunction()

function(pm_warn_devs)
    set(MSGl ${ARGN})
    __pm_list__join(MSGl "" MSG)
    message(AUTHOR_WARNING
        "-- author warning\n"
        "${MSG}\n")
endfunction()

function(pm_exit)
    set(MSGl ${ARGN})
    __pm_list__join(MSGl "" MSG)
    message(FATAL_ERROR
        "-- exit\n"
        "${MSG}\n")
endfunction()
