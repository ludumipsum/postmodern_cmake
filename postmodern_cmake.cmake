include_guard(GLOBAL)

# TODO: We should probably add a This Has Been Included var and a version here.

## Postmodern CMake
################################################################################

include(pm__core)
include(pm_autotargets)
include(pm_boolean)
include(pm_export_component)
include(pm_fail)
include(pm_install_files)
include(pm_list)
include(pm_math)
include(pm_parse_arguments)
include(pm_paths)
include(pm_proplist)
include(pm_system_information)
include(pm_targets)
include(pm_variable_group)


## Additional (unsorted) Helper Function
################################################################################

function(pm_print_target_property TARGET PROPERTY)
    set(PROP "")
    get_target_property(PROP ${TARGET} ${PROPERTY})
    # If a property is not found print "NOTFOUND", not "PROP-NOTFOUND"
    if("${PROP}" MATCHES "NOTFOUND")
        set(PROP "NOTFOUND")
    endif()
    pm_list(JOIN PROP PRETTY " ")
    pm_status("${TARGET} ${PROPERTY} :: ${PRETTY}")
endfunction()

# Like `set_target_properties` except it only sets one property on one target.
function(pm_set_target_property TARGET PROPERTY VALUE)
    set_target_properties(${TARGET} PROPERTIES ${PROPERTY} ${VALUE})
endfunction()
