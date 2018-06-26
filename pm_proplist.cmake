include_guard(GLOBAL)

include(pm__core)
include(pm_list)
include(pm_math)
include(pm_parse_arguments)

# pm_proplist(INDEX_OF_KEY <proplist_name> <out> <key>)
#
# pm_proplist(INSERT <proplist_name> <key1> <value1> [<key2> <value2> ...]
#                     [OUTPUT <out>])
# pm_proplist(EXTEND <proplist_name> <proplist_name1> [<proplist_name2> ...]
#                     [OUTPUT <out>])
#
# pm_proplist(FIND <proplist_name> <out> <key>
#                   [DEFAULT <value>])
# pm_proplist(HAS <proplist_name> <out> <key>)
#
# pm_proplist(DELETE <proplist_name> <key1> [<key2> ...]
#                     [OUTPUT <out>])
#
# pm_proplist(KEYS <proplist_name> <out>)
# pm_proplist(VALUES <proplist_name> <out>)
#
# pm_proplist(ARE_EQUAL <proplist_name> <proplist_name> <out>)


function(pm_proplist CMD)

    # pm_proplist(INDEX_OF_KEY <proplist_name> <out> <key>)
    # ----------------------------------------------------------------
    if(CMD STREQUAL INDEX_OF_KEY)
        pm_parse_arguments(
            positional_arguments PLISTpn OUTn KEY
            argn ${ARGN}
        )

        pm_list(LAST_INDEX ${PLISTpn} LI)
        if(LI LESS 0)
            set(${OUTn} -1 PARENT_SCOPE)
            return()
        endif()
        foreach(I RANGE 0 ${LI} 2)
            pm_list(GET ${PLISTpn} K ${I})
            if(KEY STREQUAL K)
                set(${OUTn} ${I} PARENT_SCOPE)
                return()
            endif()
        endforeach()

        set(${OUTn} -1 PARENT_SCOPE)


    # pm_proplist(INSERT <proplist_name> <key1> <value1> [<key2> <value2> ...]
    #              [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL INSERT)
        pm_parse_arguments(
            positional_arguments PLISTpn
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )

        pm_set_if_unset(OUTPUT ${PLISTpn})
        pm_disallow_special_names(${PLISTpn} ${OUTPUT})

        pm_math(IS_EVEN MATCHING_KV_PAIRS ${UNPARSED_ARGUMENTS_COUNT})
        if(NOT MATCHING_KV_PAIRS)
            set(args ${UNPARSED_ARGUMENTS})
            pm_list(JOIN args STR ", ")
            pm_exit(
                "pm_proplist(INSERT <proplist_name> <key1> <value1> [<key2> <value2> ...]) "
                "called with an odd number of arguments, implying offset "
                "key/value pairs: ${STR}"
            )
        endif()

        set(KV_PAIRS ${UNPARSED_ARGUMENTS})
        set(KV_PAIRS_COUNT ${UNPARSED_ARGUMENTS_COUNT})


        while(KV_PAIRS_COUNT GREATER 0)
            pm_list(POP_FRONT KV_PAIRS K V)
            pm_proplist(INDEX_OF_KEY ${PLISTpn} I ${K})

            # If the key is already in the proplist, replace the value,
            # otherwise append the KV pair to the end.
            if(${I} GREATER_EQUAL 0)
                # NB. We have to insert the new value and then remove the old
                # value in order to avoid a corner-case that's hit when trying
                # to replace the last value in the proplist; If we remove the
                # last element from a list, that index is no longer valid. If
                # we try to insert into that removed index, we will be trying
                # to insert into the one-past-the-end'th element.
                pm_math(INCREMENT I)
                pm_list(INSERT ${PLISTpn} ${I} ${V})
                pm_math(INCREMENT I)
                pm_list(REMOVE_AT ${PLISTpn} ${I})
            else()
                pm_list(APPEND ${PLISTpn} ${K} ${V})
            endif()

            pm_list(LENGTH KV_PAIRS KV_PAIRS_COUNT)
        endwhile()

        set(${OUTPUT} ${${PLISTpn}} PARENT_SCOPE)

    # pm_proplist(EXTEND <proplist_name> <proplist_name1> [<proplist_name2> ...]
    #              [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL EXTEND)
        pm_parse_arguments(
            positional_arguments PLISTpn
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )

        pm_set_if_unset(OUTPUT ${PLISTpn})
        pm_disallow_special_names(${PLISTpn} ${OUTPUT})

        foreach(Pn IN LISTS UNPARSED_ARGUMENTS)
            pm_proplist(INSERT ${PLISTpn} ${${Pn}})
        endforeach()

        set(${OUTPUT} ${${PLISTpn}} PARENT_SCOPE)

    # pm_proplist(FIND <proplist_name> <out> <key> [DEFAULT <value>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL FIND)
        pm_parse_arguments(
            positional_arguments PLISTpn OUTn KEY
            arguments DEFAULT
            argn ${ARGN}
        )

        pm_proplist(INDEX_OF_KEY ${PLISTpn} I ${KEY})

        if(${I} GREATER_EQUAL 0)
            pm_math(INCREMENT I)
            pm_list(GET ${PLISTpn} V ${I})
            set(${OUTn} ${V} PARENT_SCOPE)
        elseif(DEFINED DEFAULT)
            set(${OUTn} ${DEFAULT} PARENT_SCOPE)
        else()
            unset(${OUTn} PARENT_SCOPE)
        endif()

    # pm_proplist(HAS <proplist_name> <out> <key>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL HAS)
        pm_parse_arguments(
            positional_arguments PLISTpn OUTn KEY
            argn ${ARGN}
        )

        pm_proplist(INDEX_OF_KEY ${PLISTpn} I ${KEY})

        if(${I} GREATER_EQUAL 0)
            set(${OUTn} TRUE PARENT_SCOPE)
        else()
            set(${OUTn} FALSE PARENT_SCOPE)
        endif()


    # pm_proplist(DELETE <proplist_name> <key1> [<key2> ...] [OUTPUT <out>])
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL DELETE)
        pm_parse_arguments(
            positional_arguments PLISTpn
            arguments OUTPUT
            allow_unparsed_arguments
            argn ${ARGN}
        )

        pm_set_if_unset(OUTPUT ${PLISTpn})
        pm_disallow_special_names(${PLISTpn} ${OUTPUT})

        foreach(KEY IN LISTS UNPARSED_ARGUMENTS)
            pm_proplist(INDEX_OF_KEY ${PLISTpn} I ${KEY})
            if(${I} GREATER_EQUAL 0)
                pm_math(INCREMENT I OUTPUT J)
                pm_list(REMOVE_AT ${PLISTpn} ${I} ${J})
            endif()
        endforeach()

        set(${OUTPUT} ${${PLISTpn}} PARENT_SCOPE)


    # pm_proplist(KEYS <proplist_name> <out>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL KEYS)
        pm_parse_arguments(
            positional_arguments PLISTpn OUTn
            argn ${ARGN}
        )

        pm_disallow_special_names(${PLISTpn} ${OUTn})

        pm_list(LAST_INDEX ${PLISTpn} LI)
        if(LI LESS 0)
            return()
        endif()

        set(KEYS)
        foreach(I RANGE 0 ${LI} 2)
            pm_list(GET ${PLISTpn} K ${I})
            pm_list(APPEND KEYS ${K})
        endforeach()

        set(${OUTn} ${KEYS} PARENT_SCOPE)

    # pm_proplist(VALUES <proplist_name> <out>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL VALUES)
        pm_parse_arguments(
            positional_arguments PLISTpn OUTn
            argn ${ARGN}
        )

        pm_disallow_special_names(${PLISTpn} ${OUTn})

        set(VALS)
        pm_list(LAST_INDEX ${PLISTpn} LI)
        foreach(I RANGE 1 ${LI} 2)
            pm_list(GET ${PLISTpn} V ${I})
            pm_list(APPEND VALS ${V})
        endforeach()

        set(${OUTn} ${VALS} PARENT_SCOPE)


    # pm_proplist(ARE_EQUAL <proplist_name> <proplist_name> <out>)
    # ----------------------------------------------------------------
    elseif(CMD STREQUAL ARE_EQUAL)
        pm_parse_arguments(
            positional_arguments LHSpn RHSpn OUTn
            argn ${ARGN}
        )
        pm_disallow_special_names(${LHSpn} ${RHSpn} ${OUTn})

        pm_proplist(KEYS ${LHSpn} LHS_KEYS)
        pm_proplist(KEYS ${RHSpn} RHS_KEYS)

        # We can't pass empty lists into list(SORT), so early-out in that case.
        pm_list(LENGTH LHS_KEYS LHS_KEYS_LEN)
        pm_list(LENGTH RHS_KEYS RHS_KEYS_LEN)
        if(LHS_KEYS_LEN EQUAL 0 AND RHS_KEYS_LEN EQUAL 0)
            set(${OUTn} TRUE PARENT_SCOPE)
            return()
        elseif(LHS_KEYS_LEN EQUAL 0 OR RHS_KEYS_LEN EQUAL 0)
            set(${OUTn} FALSE PARENT_SCOPE)
            return()
        endif()

        pm_list(SORT LHS_KEYS)
        pm_list(SORT RHS_KEYS)

        pm_list(COMPARE LHS_KEYS RHS_KEYS HAS_SAME_KEYS)
        if(NOT HAS_SAME_KEYS EQUAL 0)
            set(${OUTn} FALSE PARENT_SCOPE)
            return()
        endif()

        foreach(KEY IN LISTS LHS_KEYS)
            pm_proplist(FIND ${LHSpn} LHS_VAL ${KEY})
            pm_proplist(FIND ${RHSpn} RHS_VAL ${KEY})

            if(NOT LHS_VAL STREQUAL RHS_VAL)
                set(${OUTn} FALSE PARENT_SCOPE)
                return()
            endif()
        endforeach()

        set(${OUTn} TRUE PARENT_SCOPE)

    else()
        pm_exit("pm_proplist: unknown commad; ${CMD}")

    endif()
endfunction()
