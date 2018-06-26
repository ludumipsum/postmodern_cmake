# NB. We don't include_guard this file set; every time it's included, all tests
# should be allowed to run.

include(pm__core)
include(pm_proplist)  # system under test
include(pm_fail)      # required to fail the tests out
include(pm_list)      # required to compare lists

function(pm_run_proplist_tests)
    pm_status("Running Postmodern Proplist Test suite")


    # pm_proplist(ARE_EQUAL) & pm_proplist(INSERT)
    # ----------------------------------------------
    set(CONTROLp "A" "hello" "B" "world" "Bar" "Baz")

    unset(TESTp)
    pm_proplist(INSERT TESTp
        "A" "hello"
        "B" "world"
        "Bar" "Baz"
    )
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS EQ)

    unset(TESTp)
    pm_proplist(INSERT TESTp
        "Bar" "Baz"
        "B" "world"
        "A" "hello"
    )
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS EQ)


    unset(TESTp)
    pm_proplist(INSERT TESTp
        "A" "goodbye"
        "B" "person"
        "Bar" "Baz"
    )
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS NOT EQ)

    pm_proplist(INSERT TESTp
        "A" "hello"
        "B" "world"
        OUTPUT TESTp2
    )
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS NOT EQ)
    pm_proplist(ARE_EQUAL TESTp2 CONTROLp EQ)
    pm_fail(UNLESS EQ)

    pm_proplist(INSERT TESTp
        "A" "hello"
        "B" "world"
    )
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS EQ)


    # pm_proplist(EXTEND)
    # --------------------
    set(CONTROLp "A" "hello" "B" "world" "Bar" "Baz")

    unset(TESTp)
    pm_proplist(INSERT PL1
        "A"   "this"
        "B"   "is"
        "Bar" "wrong"
    )
    pm_proplist(INSERT PL2
        "A" "still bad"
        "B" "world"
    )
    pm_proplist(INSERT PL3
        "A" "hello"
        "Bar" "Baz"
    )

    pm_proplist(EXTEND PL1 PL2 PL3 OUTPUT TESTp)
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS EQ)

    pm_proplist(EXTEND PL1 PL2 PL3)
    pm_proplist(ARE_EQUAL PL1 CONTROLp EQ)
    pm_fail(UNLESS EQ)


    # pm_proplist(FIND) & pm_proplist(HAS)
    # --------------------------------------
    unset(TESTp)
    pm_proplist(INSERT TESTp
        "A"   "hello"
        "B"   "world"
        "Bar" "Baz"
    )

    pm_proplist(HAS TESTp HAS_B "B")
    pm_fail(UNLESS HAS_B)
    pm_proplist(FIND TESTp VAL "B")
    pm_fail(UNLESS VAL STREQUAL "world")

    pm_proplist(HAS TESTp HAS_NOT_A_KEY "NOT_A_KEY")
    pm_fail(IF HAS_NOT_A_KEY)
    pm_proplist(FIND TESTp VAL "NOT_A_KEY")
    pm_fail(IF_SET VAL)

    pm_proplist(HAS TESTp HAS_NOT_A_KEY "NOT_A_KEY")
    pm_fail(IF HAS_NOT_A_KEY)
    pm_proplist(FIND TESTp VAL "NOT_A_KEY" DEFAULT "A default value")
    pm_fail(UNLESS VAL STREQUAL "A default value")


    # pm_proplist(DELETE)
    # --------------------
    unset(TESTp)
    pm_proplist(INSERT TESTp
        "A"   "hello"
        "B"   "world"
        "Bar" "Baz"
    )

    pm_proplist(DELETE TESTp "Bar")
    unset(CONTROLp)
    pm_proplist(INSERT CONTROLp
        "B" "world"
        "A" "hello"
    )

    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS EQ)

    pm_proplist(DELETE TESTp "A" "B")
    unset(CONTROLp)
    pm_proplist(ARE_EQUAL TESTp CONTROLp EQ)
    pm_fail(UNLESS EQ)


    # pm_proplist(KEYS)
    # ------------------
    unset(TESTp)
    pm_proplist(INSERT TESTp
        "A"   "hello"
        "B"   "world"
        "Bar" "Baz"
    )
    set(CONTROLl "A" "B" "Bar")

    pm_proplist(KEYS TESTp TESTp_KEYS)
    pm_list(COMPARE TESTp_KEYS CONTROLl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_proplist(VALUES)
    # --------------------
    unset(TESTp)
    pm_proplist(INSERT TESTp
        "A"   "hello"
        "B"   "world"
        "Bar" "Baz"
    )
    set(CONTROLl "hello" "world" "Baz")

    pm_proplist(VALUES TESTp TESTp_VALUES)
    pm_list(COMPARE TESTp_VALUES CONTROLl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    pm_status("Running Postmodern Proplist Test suite -- done")
endfunction()
