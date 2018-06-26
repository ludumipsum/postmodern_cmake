include_guard(GLOBAL)

include(pm__core)
include(pm_boolean)
include(pm_parse_arguments)
include(pm_variable_group)


function(pm_fail)
    pm_parse_arguments(
        list_arguments
            IF
            WHEN
            IF_NOT
            UNLESS
            WHEN_NOT
            IF_SET
            IF_NOT_SET
            MESSAGE
            WITH
            SAYING
        argn ${ARGN}
    )

    pm_variable_group(
        NAME
            CONDITIONAL_PARAMS
        VARIABLES
            IF
            WHEN
            IF_NOT
            UNLESS
            WHEN_NOT
            IF_SET
            IF_NOT_SET
        CAPTURE_NUMBER_SET
        CAPTURE_SET_LIST
    )
    pm_variable_group(
        NAME
            MESSAGE_PARAMS
        VARIABLES
            MESSAGE
            WITH
            SAYING
        CAPTURE_NUMBER_SET
        CAPTURE_SET_LIST
    )

    if(${CONDITIONAL_PARAMS_NUMBER_SET} GREATER 1)
        __pm_list__join(CONDITIONAL_PARAMS_SET_LIST ", " PRETTY)
        pm_exit(
            "`pm_fail` must be given zero or one Condition Commands. "
            "Conflicting Condition Commands:\n"
            "${PRETTY}"
        )
    endif()

    if(${MESSAGE_PARAMS_NUMBER_SET} GREATER 1)
        __pm_list__join(MESSAGE_PARAMS_SET_LIST ", " PRETTY)
        pm_exit(
            "`pm_fail` must be given zero or one Condition Commands. "
            "Conflicting Condition Commands:\n"
            "${PRETTY}"
        )
    endif()


    set(CONDITION_MET FALSE)
    if(${CONDITIONAL_PARAMS_NUMBER_SET} EQUAL 0)
        # If no conditional expression was given, default to true
        set(CONDITION_MET TRUE)
        set(PRETTY_MESSAGE "Unconditional pm_fail() encountered")
    elseif(DEFINED IF)
        if(${IF})
            set(CONDITION_MET TRUE)
            __pm_list__join(IF " " CONDITION_STRING)
            set(CONDITION_STRING "Condition: IF ${CONDITION_STRING}\n")
        endif()
    elseif(DEFINED WHEN)
        if(${WHEN})
            set(CONDITION_MET TRUE)
            __pm_list__join(WHEN " " CONDITION_STRING)
            set(CONDITION_STRING "Condition: WHEN ${CONDITION_STRING}\n")
        endif()
    elseif(DEFINED IF_NOT)
        if(NOT (${IF_NOT}))
            set(CONDITION_MET TRUE)
            __pm_list__join(IF_NOT " " CONDITION_STRING)
            set(CONDITION_STRING "Condition Unmet: IF_NOT ${CONDITION_STRING}\n")
        endif()
    elseif(DEFINED UNLESS)
        if(NOT (${UNLESS}))
            set(CONDITION_MET TRUE)
            __pm_list__join(UNLESS " " CONDITION_STRING)
            set(CONDITION_STRING "Condition Unmet: UNLESS ${CONDITION_STRING}\n")
        endif()
    elseif(DEFINED WHEN_NOT)
        if(NOT (${WHEN_NOT}))
            set(CONDITION_MET TRUE)
            __pm_list__join(WHEN_NOT " " CONDITION_STRING)
            set(CONDITION_STRING "Condition Unmet: WHEN_NOT ${CONDITION_STRING}\n")
        endif()
    elseif(DEFINED IF_SET)
        if(DEFINED ${IF_SET})
            set(CONDITION_MET TRUE)
            set(CONDITION_STRING "Condition: ${IF_SET} is defined\n")
        endif()
    elseif(DEFINED IF_NOT_SET)
        if(NOT (DEFINED ${IF_NOT_SET}))
            set(CONDITION_MET TRUE)
            set(CONDITION_STRING "Condition: ${IF_NOT_SET} is not defined\n")
        endif()
    endif()

    if(CONDITION_MET)
        if(${MESSAGE_PARAMS_NUMBER_SET} EQUAL 1)
            set(PRETTY_MESSAGE ${MESSAGE} ${WITH} ${SAYING})
        endif()
        pm_exit(${CONDITION_STRING} ${PRETTY_MESSAGE})
    endif()
endfunction()
