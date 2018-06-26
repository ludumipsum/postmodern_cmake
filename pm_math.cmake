include_guard(GLOBAL)

include(pm__core)
include(pm_parse_arguments)


function(pm_math CMD)

    # pm_math(EXPR <out> <expression>)
    # ----------------------------------------------------------------
    if(CMD STREQUAL EXPR)
        pm_parse_arguments(
            positional_arguments OUTn MATH_EXPR
            argn ${ARGN}
        )
        pm_disallow_special_names(${OUTn})

        math(EXPR RET ${MATH_EXPR})
        set(${OUTn} ${RET} PARENT_SCOPE)

    # pm_math(MIN <out> <num1> [<num2> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL MIN)
        pm_parse_arguments(
            positional_arguments OUTn
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_math(MIN <out> <num1> [<num2> ...]) "
                "called with too few arguments"
            )
        endif()

        list(GET UNPARSED_ARGUMENTS 0 RET)
        list(REMOVE_AT UNPARSED_ARGUMENTS 0)

        foreach(N IN LISTS UNPARSED_ARGUMENTS)
            if(N LESS RET)
                set(RET ${N})
            endif()
        endforeach()

        set(${OUTn} ${RET} PARENT_SCOPE)

    # pm_math(MAX <out> <num1> [<num2> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL MAX)
        pm_parse_arguments(
            positional_arguments OUTn
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_math(MAX <out> <num1> [<num2> ...]) "
                "called with too few arguments"
            )
        endif()

        list(GET UNPARSED_ARGUMENTS 0 RET)
        list(REMOVE_AT UNPARSED_ARGUMENTS 0)

        foreach(N IN LISTS UNPARSED_ARGUMENTS)
            if(N GREATER RET)
                set(RET ${N})
            endif()
        endforeach()

        set(${OUTn} ${RET} PARENT_SCOPE)

    # pm_math(IS_EVEN <out> <num>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL IS_EVEN)
        pm_parse_arguments(
            positional_arguments OUTn NUM
            argn ${ARGN}
        )

        math(EXPR CHECK "(${NUM} / 2) * 2")
        if(${NUM} EQUAL ${CHECK})
            set(${OUTn} TRUE PARENT_SCOPE)
        else()
            set(${OUTn} FALSE PARENT_SCOPE)
        endif()


    # pm_math(IS_ODD <out> <num>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL IS_ODD)
        pm_parse_arguments(
            positional_arguments OUTn NUM
            argn ${ARGN}
        )

        math(EXPR CHECK "(${NUM} / 2) * 2")
        if(${NUM} EQUAL ${CHECK})
            set(${OUTn} FALSE PARENT_SCOPE)
        else()
            set(${OUTn} TRUE PARENT_SCOPE)
        endif()


    # pm_math(INCREMENT <var> [BY <num>] [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL INCREMENT)
        pm_parse_arguments(
            positional_arguments VARn
            arguments BY OUTPUT
            argn ${ARGN}
        )

        pm_set_if_unset(BY 1)
        pm_set_if_unset(OUTPUT ${VARn})

        math(EXPR RET "${${VARn}} + ${BY}")
        set(${OUTPUT} ${RET} PARENT_SCOPE)


    # pm_math(DECREMENT <var> [BY <num>] [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL DECREMENT)
        pm_parse_arguments(
            positional_arguments VARn
            arguments BY OUTPUT
            argn ${ARGN}
        )

        pm_set_if_unset(BY 1)
        pm_set_if_unset(OUTPUT ${VARn})

        math(EXPR RET "${${VARn}} - ${BY}")
        set(${OUTPUT} ${RET} PARENT_SCOPE)


    # pm_math(DOUBLE <var> [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL DOUBLE)
        pm_parse_arguments(
            positional_arguments VARn
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_set_if_unset(OUTPUT ${VARn})

        math(EXPR RET "${${VARn}} * 2")
        set(${OUTPUT} ${RET} PARENT_SCOPE)


    # pm_math(HALVE <var> [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL HALVE)
        pm_parse_arguments(
            positional_arguments VARn
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_set_if_unset(OUTPUT ${VARn})

        math(EXPR RET "${${VARn}} / 2")
        set(${OUTPUT} ${RET} PARENT_SCOPE)


    else()
        pm_exit("pm_math: given unknown commad; ${CMD}")

    endif()
endfunction()
