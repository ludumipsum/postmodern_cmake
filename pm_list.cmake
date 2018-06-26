include_guard(GLOBAL)

include(pm__core)
include(pm_math)
include(pm_parse_arguments)

# NB. `pm_list` uses the leading outvar calling convention (rather than the
# trailling outvars that CMake's `list` uses), which means we're breaking with
# CMake's calling convention in a few places. Notably GET, and FIND.


function(pm_list CMD)

    # pm_list(PUSH_FRONT <list_name> <element1> [<element2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    if(CMD STREQUAL PUSH_FRONT)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(PUSH_FRONT <list_name> <element1> [<element2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        set(${OUTPUT} ${UNPARSED_ARGUMENTS} ${${LISTln}} PARENT_SCOPE)

    # pm_list(PUSH_BACK <list_name> <element1> [<element2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL PUSH_BACK)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(PUSH_BACK <list_name> <element1> [<element2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        set(${OUTPUT} ${${LISTln}} ${UNPARSED_ARGUMENTS} PARENT_SCOPE)

    # pm_list(POP_FRONT <list_name> <out1> [<out2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL POP_FRONT)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(POP_FRONT <list_name> <out1> [<out2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(LENGTH UNPARSED_ARGUMENTS NAME_LIST_LEN)
        list(LENGTH ${LISTln}          VAL_LIST_LEN)
        if(NAME_LIST_LEN GREATER VAL_LIST_LEN)
            pm_exit(
                "Attempting to extract ${NAME_LIST_LEN} elements from a list "
                "with only ${VAL_LIST_LEN} elements!"
            )
        endif()

        foreach(N IN LISTS UNPARSED_ARGUMENTS)
            # If the outvar is named `"_"` skip over the current list element.
            if(N STREQUAL "_")
                list(REMOVE_AT ${LISTln} 0)
                continue()
            endif()

            pm_disallow_special_names(${N})
            list(GET ${LISTln} 0 V)
            list(REMOVE_AT ${LISTln} 0)
            set(${N} ${V} PARENT_SCOPE)
        endforeach()

        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(POP_BACK <list_name> <out1> [<out2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL POP_BACK)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(POP_BACK <list_name> <out1> [<out2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(LENGTH UNPARSED_ARGUMENTS NAME_LIST_LEN)
        list(LENGTH ${LISTln}          VAL_LIST_LEN)
        if(NAME_LIST_LEN GREATER VAL_LIST_LEN)
            pm_exit(
                "Attempting to extract ${NAME_LIST_LEN} elements from a list "
                "with only ${VAL_LIST_LEN} elements!"
            )
        endif()

        foreach(N IN LISTS UNPARSED_ARGUMENTS)
            # If the outvar is named `"_"` skip over the current list element.
            if(N STREQUAL "_")
                list(REMOVE_AT ${LISTln} -1)
                continue()
            endif()

            pm_disallow_special_names(${N})
            list(GET ${LISTln} -1 V)
            list(REMOVE_AT ${LISTln} -1)
            set(${N} ${V} PARENT_SCOPE)
        endforeach()

        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(PEEK_FRONT <list_name> <out1> [<out2> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL PEEK_FRONT)
        pm_parse_arguments(
            positional_arguments LISTln
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(PEEK_FRONT <list_name> <out1> [<out2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})

        list(LENGTH ${LISTln} VAL_LIST_LEN)
        if(UNPARSED_ARGUMENTS_COUNT GREATER VAL_LIST_LEN)
            pm_exit(
                "Attempting to extract ${UNPARSED_ARGUMENTS_COUNT} elements "
                "from a list with only ${VAL_LIST_LEN} elements!"
            )
        endif()

        foreach(N IN LISTS UNPARSED_ARGUMENTS)
            # If the outvar is named `"_"` skip over the current list element.
            if(N STREQUAL "_")
                pm_list(POP_FRONT ${LISTln} _)
                continue()
            endif()

            pm_disallow_special_names(${N})
            pm_list(POP_FRONT ${LISTln} V)
            set(${N} ${V} PARENT_SCOPE)
        endforeach()

    # pm_list(PEEK_BACK <list_name> <out1> [<out2> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL PEEK_BACK)
        pm_parse_arguments(
            positional_arguments LISTln
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(PEEK_BACK <list_name> <out1> [<out2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})

        list(LENGTH ${LISTln} VAL_LIST_LEN)
        if(UNPARSED_ARGUMENTS_COUNT GREATER VAL_LIST_LEN)
            pm_exit(
                "Attempting to extract ${UNPARSED_ARGUMENTS_COUNT} elements "
                "from a list with only ${VAL_LIST_LEN} elements!"
            )
        endif()

        foreach(N IN LISTS UNPARSED_ARGUMENTS)
            # If the outvar is named `"_"` skip over the current list element.
            if(N STREQUAL "_")
                pm_list(POP_BACK ${LISTln} _)
                continue()
            endif()

            pm_disallow_special_names(${N})
            pm_list(POP_BACK ${LISTln} V)
            set(${N} ${V} PARENT_SCOPE)
        endforeach()

    # pm_list(APPEND <list_name> <element1> [<element2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL APPEND)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(APPEND <list_name> <element1> [<element2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(APPEND ${LISTln} ${UNPARSED_ARGUMENTS})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(INSERT <list_name> <index> <element1> [<element2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL INSERT)
        pm_parse_arguments(
            positional_arguments LISTln INDEX
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(INSERT <list_name> <index> <element1> [<element2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(INSERT ${LISTln} ${INDEX} ${UNPARSED_ARGUMENTS})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(EXTEND <list_name> <list1> [<list2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL EXTEND)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(EXTEND <list_name> <list1> [<list2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        foreach(Ln IN LISTS ${UNPARSED_ARGUMENTS})
            pm_disallow_special_names(${Ln})
            list(APPEND ${LISTln} ${Ln})
        endforeach()

        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(FILTER <list_name> <INCLUDE|EXCLUDE> REGEX <regular_expression>
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL FILTER)
        pm_parse_arguments(
            positional_arguments LISTln FILTER_TYPE _ REXPR
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(FILTER ${LISTln} ${FILTER_TYPE} REGEX ${REXPR})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(REMOVE_ITEM <list_name> <element1> [<element2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL REMOVE_ITEM)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(REMOVE_ITEM <list_name> <elemen1> [<element2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(REMOVE_ITEM ${LISTln} ${UNPARSED_ARGUMENTS})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(REMOVE_AT <list_name> <index1> [<index2> ...]
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL REMOVE_AT)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(REMOVE_AT <list_name> <index1> [<index2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(REMOVE_AT ${LISTln} ${UNPARSED_ARGUMENTS})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(REMOVE_DUPLICATES <list_name>
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL REMOVE_DUPLICATES)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(REMOVE_DUPLICATES ${LISTln})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)


    # pm_list(LENGTH <list_name> <out>)
    # ----------------------------------------------------------------\
    elseif(CMD STREQUAL LENGTH)
        pm_parse_arguments(
            positional_arguments LISTln OUTn
            argn ${ARGN}
        )

        # We're not going to be generating unparsed arguments or unset
        # parameters, so it's safe to take the length pm_parse_args variables.
        pm_loosely_disallow_special_names(${LISTln} ${OUTn})

        list(LENGTH ${LISTln} LEN)
        set(${OUTn} ${LEN} PARENT_SCOPE)

    # pm_list(LAST_INDEX <list_name> <out>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL LAST_INDEX)
        pm_parse_arguments(
            positional_arguments LISTln OUTn
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln} ${OUTn})

        list(LENGTH ${LISTln} LEN)
        pm_math(DECREMENT LEN)
        set(${OUTn} ${LEN} PARENT_SCOPE)


    # pm_list(GET <list_name> <out> <index1> [<index1> ...])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL GET)
        pm_parse_arguments(
            positional_arguments LISTln OUTn
            allow_unparsed_arguments
            argn ${ARGN}
        )
        if(NOT UNPARSED_ARGUMENTS_COUNT GREATER_EQUAL 1)
            pm_exit(
                "pm_list(GET <list_name> <out> <index1> [<index2> ...]) "
                "called with too few arguments"
            )
        endif()

        pm_disallow_special_names(${LISTln} ${OUTn})

        # Convenience check to call out that we've broken with CMake's signature
        if(OUTn MATCHES "[0-9]+")
            pm_warn_devs(
                "pm_list(GET <list_name> <out> <index1> [<index2> ...]) "
                "was given an out variable named \"${OUTn}\". Was that "
                "supposed to be a fetched index?"
            )
        endif()

        list(GET ${LISTln} ${UNPARSED_ARGUMENTS} RET)
        set(${OUTn} ${RET} PARENT_SCOPE)

    # pm_list(FIND <list_name> <out> <value>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL FIND)
        pm_parse_arguments(
            positional_arguments LISTln OUTn VALUE
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln} ${OUTn})

        list(FIND ${LISTln} ${VALUE} RET)
        set(${OUTn} ${RET} PARENT_SCOPE)


    # pm_list(REVERSE <list_name>
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL REVERSE)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(REVERSE ${LISTln})
        set(${OUTPUT} ${${LISTln}} PARENT_SCOPE)

    # pm_list(SORT <list_name>
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL SORT)
        pm_parse_arguments(
            positional_arguments LISTln
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        list(SORT ${LISTln})
        set(${LISTln} ${${LISTln}} PARENT_SCOPE)


    # pm_list(PREFIX_EACH <list_name> <prefix>
    #          [OUTPUT <list_name>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL PREFIX_EACH)
        pm_parse_arguments(
            positional_arguments LISTln PREFIX
            arguments OUTPUT
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln})
        pm_set_if_unset(OUTPUT ${LISTln})

        set(RET)
        foreach(E IN LISTS ${LISTln})
            list(APPEND RET ${PREFIX}${E})
        endforeach()

        set(${OUTPUT} ${RET} PARENT_SCOPE)

    # pm_list(JOIN <list_name> <out> <glue>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL JOIN)
        pm_parse_arguments(
            positional_arguments LISTln OUTn GLUE
            argn ${ARGN}
        )

        pm_disallow_special_names(${LISTln} ${OUTn})

        __pm_list__join(${LISTln} ${GLUE} RET)
        set(${OUTn} ${RET} PARENT_SCOPE)


    # pm_list(COMPARE <list_name> <list_name> <out>)
    # ----------------------------------------------------------------\
    elseif(CMD STREQUAL COMPARE)
        pm_parse_arguments(
            positional_arguments LHSln RHSln OUTn
            argn ${ARGN}
        )

        pm_disallow_special_names(${LHSln} ${RHSln} ${OUTn})

        pm_list(LAST_INDEX ${LHSln} LHS_LI)
        pm_list(LAST_INDEX ${RHSln} RHS_LI)
        pm_math(MIN MIN_LI ${LHS_LI} ${RHS_LI})

        foreach(I RANGE ${MIN_LI})
            pm_list(GET ${LHSln} L ${I})
            pm_list(GET ${RHSln} R ${I})
            if(L STRLESS R)
                set(${OUTn} -1 PARENT_SCOPE)
                return()
            elseif(L STRGREATER R)
                set(${OUTn} 1 PARENT_SCOPE)
                return()
            endif()
        endforeach()

        # All comparable elements are equal; if one list is longer than the
        # other, it is the greater of the two. If they're of equal length,
        # the lists are equal.
        if(LHS_LI GREATER MIN_LI)
            set(${OUTn} 1 PARENT_SCOPE)
            return()
        elseif(RHS_LI GREATER MIN_LI)
            set(${OUTn} -1 PARENT_SCOPE)
            return()
        endif()

        set(${OUTn} 0 PARENT_SCOPE)


    else()
        pm_exit("pm_list: given unknown commad; ${CMD}")

    endif()
endfunction()
