# NB. We don't include_guard this file set; every time it's included, all tests
# should be allowed to run.

include(pm__core)
include(pm_list)   # system under test
include(pm_fail)   # required to fail the tests out

function(pm_run_list_tests)
    message(STATUS "Running Postmodern List Test suite")


    # pm_list(COMPARE)
    # -----------------
    set(CONTROLl 1 2 3 4 5)

    set(TESTl    1 2 3 4 5)
    pm_list(COMPARE TESTl CONTROLl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl    1 2 3 4)
    pm_list(COMPARE TESTl CONTROLl CMP)
    pm_fail(UNLESS ${CMP} LESS 0)

    set(TESTl    1 2 3 4 5 6)
    pm_list(COMPARE TESTl CONTROLl CMP)
    pm_fail(UNLESS ${CMP} GREATER 0)

    set(TESTl    1 2 3 4 6)
    pm_list(COMPARE TESTl CONTROLl CMP)
    pm_fail(UNLESS ${CMP} GREATER 0)

    set(TESTl    1 2 3 4 4)
    pm_list(COMPARE TESTl CONTROLl CMP)
    pm_fail(UNLESS ${CMP} LESS 0)


    # pm_list(PUSH_FRONT)
    # --------------------
    set(TESTl     2 3 4 5)
    set(EXPECTl 1 2 3 4 5)
    pm_list(PUSH_FRONT TESTl 1)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl       3 4 5)
    set(EXPECTl 1 2 3 4 5)
    pm_list(PUSH_FRONT TESTl 1 2)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl            3 4 5)
    set(EXPECT_OUTl  1 2 3 4 5)
    set(EXPECT_TESTl     3 4 5)
    pm_list(PUSH_FRONT TESTl 1 2 OUTPUT OUTl)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl            3 4 5)
    set(EXPECT_OUTl  1 2 3 4 5)
    set(EXPECT_TESTl     3 4 5)
    pm_list(PUSH_FRONT TESTl OUTPUT OUTl 1 2)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(PUSH_BACK)
    # -------------------
    set(TESTl   1 2 3 4)
    set(EXPECTl 1 2 3 4 5)
    pm_list(PUSH_BACK TESTl 5)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl   1 2 3)
    set(EXPECTl 1 2 3 4 5)
    pm_list(PUSH_BACK TESTl 4 5)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl        1 2 3)
    set(EXPECT_OUTl  1 2 3 4 5)
    set(EXPECT_TESTl 1 2 3)
    pm_list(PUSH_BACK TESTl 4 5 OUTPUT OUTl)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl        1 2 3)
    set(EXPECT_OUTl  1 2 3 4 5)
    set(EXPECT_TESTl 1 2 3)
    pm_list(PUSH_BACK TESTl OUTPUT OUTl 4 5)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(POP_FRONT)
    # -------------------
    set(TESTl   1 2 3 4 5 6)
    set(EXPECTl   2 3 4 5 6)
    pm_list(POP_FRONT TESTl A)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 1)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(EXPECTl        4 5 6)
    pm_list(POP_FRONT TESTl A B)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 2)
    pm_fail(UNLESS ${B} EQUAL 3)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(EXPECTl)
    pm_list(POP_FRONT TESTl A B C)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 4)
    pm_fail(UNLESS ${B} EQUAL 5)
    pm_fail(UNLESS ${C} EQUAL 6)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    set(TESTl        1 2 3 4 5)
    set(EXPECT_OUTl      3 4 5)
    set(EXPECT_TESTl 1 2 3 4 5)
    pm_list(POP_FRONT TESTl A B OUTPUT OUTl)
    pm_fail(UNLESS ${A} EQUAL 1)
    pm_fail(UNLESS ${B} EQUAL 2)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl        1 2 3 4 5)
    set(EXPECT_OUTl      3 4 5)
    set(EXPECT_TESTl 1 2 3 4 5)
    pm_list(POP_FRONT TESTl OUTPUT OUTl A B)
    pm_fail(UNLESS ${A} EQUAL 1)
    pm_fail(UNLESS ${B} EQUAL 2)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(POP_BACK)
    # ------------------
    set(TESTl   1 2 3 4 5 6)
    set(EXPECTl 1 2 3 4 5)
    pm_list(POP_BACK TESTl A)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 6)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(EXPECTl  1 2 3)
    pm_list(POP_BACK TESTl A B)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 5)
    pm_fail(UNLESS ${B} EQUAL 4)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(EXPECTl)
    pm_list(POP_BACK TESTl A B C)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 3)
    pm_fail(UNLESS ${B} EQUAL 2)
    pm_fail(UNLESS ${C} EQUAL 1)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl        1 2 3 4 5)
    set(EXPECT_OUTl  1 2 3)
    set(EXPECT_TESTl 1 2 3 4 5)
    pm_list(POP_BACK TESTl A B OUTPUT OUTl)
    pm_fail(UNLESS ${A} EQUAL 5)
    pm_fail(UNLESS ${B} EQUAL 4)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl        1 2 3 4 5)
    set(EXPECT_OUTl  1 2 3)
    set(EXPECT_TESTl 1 2 3 4 5)
    pm_list(POP_BACK TESTl OUTPUT OUTl A B)
    pm_fail(UNLESS ${A} EQUAL 5)
    pm_fail(UNLESS ${B} EQUAL 4)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(PEEK_FRONT)
    # --------------------
    set(TESTl   1 2 3 4 5 6)
    set(EXPECTl 1 2 3 4 5 6)

    pm_list(PEEK_FRONT TESTl A)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 1)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    pm_list(PEEK_FRONT TESTl A B)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 1)
    pm_fail(UNLESS ${B} EQUAL 2)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(PEEK_BACK)
    # -------------------
    set(TESTl   1 2 3 4 5 6)
    set(EXPECTl 1 2 3 4 5 6)

    pm_list(PEEK_BACK TESTl A)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 6)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    pm_list(PEEK_BACK TESTl A B)
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${A} EQUAL 6)
    pm_fail(UNLESS ${B} EQUAL 5)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(EXTEND)
    # ----------------
    set(CONTROLl  1 2 3 4 5 6)

    set(TESTl    1 2 3)
    set(TESTl_2  4 5 6)
    pm_list(EXTEND TESTl TESTl_2)
    pm_list(COMPARE TESTl CONTROLl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl    1 2 3)
    set(TESTl_2  4 5)
    set(TESTl_3  6)
    set(EXPECT_OUTl  1 2 3 4 5 6)
    set(EXPECT_TESTl 1 2 3)
    pm_list(EXTEND TESTl TESTl_2 TESTl_3 OUTPUT OUTl)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl    1 2 3)
    set(TESTl_2  4 5)
    set(TESTl_3  6)
    set(EXPECT_OUTl  1 2 3 4 5 6)
    set(EXPECT_TESTl 1 2 3)
    pm_list(EXTEND TESTl OUTPUT OUTl TESTl_2 TESTl_3)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(LAST_INDEX)
    # --------------------
    set(TESTl  1 2 3)
    pm_list(LAST_INDEX TESTl LI)
    pm_fail(UNLESS ${LI} EQUAL 2)

    set(TESTl  1 2 3 4 5 6)
    pm_list(LAST_INDEX TESTl LI)
    pm_fail(UNLESS ${LI} EQUAL 5)

    set(TESTl)
    pm_list(LAST_INDEX TESTl LI)
    pm_fail(UNLESS ${LI} EQUAL -1)


    # pm_list(PREFIX_EACH)
    # ---------------------
    set(TESTl    1  2  3  4)
    set(EXPECTl a1 a2 a3 a4)
    pm_list(PREFIX_EACH TESTl "a")
    pm_list(COMPARE TESTl EXPECTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    set(TESTl         1  2  3  4)
    set(EXPECT_OUTl  b1 b2 b3 b4)
    set(EXPECT_TESTl  1  2  3  4)
    pm_list(PREFIX_EACH TESTl "b" OUTPUT OUTl)
    pm_list(COMPARE OUTl EXPECT_OUTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)
    pm_list(COMPARE TESTl EXPECT_TESTl CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    # pm_list(JOIN)
    # --------------
    set(TESTT 1 2 3 4)
    pm_list(JOIN TESTl TEST_STR ", ")
    pm_fail(UNLESS "${TEST_STR}" STREQUAL "1, 2, 3, 4")
    pm_list(JOIN TESTl TEST_STR " and a ")
    pm_fail(UNLESS "${TEST_STR}" STREQUAL "1 and a 2 and a 3 and a 4")


    # CMake passthroughs;

    # [pm_]list(LENGTH)
    # ------------------
    set(TESTl  1 2 3)

    list(LENGTH    TESTl LEN_CM)
    pm_list(LENGTH TESTl LEN_PM)
    pm_fail(UNLESS ${LEN_CM} EQUAL ${LEN_PM})

    # [pm_]list(GET)
    # ---------------
    set(TESTl  1 2 3)

    list(GET    TESTl      1 2 L_CM)
    pm_list(GET TESTl L_PM 1 2)
    pm_list(COMPARE L_CM L_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(APPEND)
    # ------------------
    set(TESTl_CM  1 2 3)
    set(TESTl_PM  1 2 3)

    list(APPEND    TESTl_CM 1 2)
    pm_list(APPEND TESTl_PM 1 2)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(FILTER)
    # ------------------
    set(TESTl_CM  1 a 2 b 3 c)
    set(TESTl_PM  1 a 2 b 3 c)

    list(FILTER    TESTl_CM EXCLUDE REGEX "[a-z]")
    pm_list(FILTER TESTl_PM EXCLUDE REGEX "[a-z]")
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(FIND)
    # ---------------
    set(TESTl  A B C)

    list(FIND    TESTl      B I_CM)
    pm_list(FIND TESTl I_PM B)
    pm_fail(UNLESS ${I_CM} EQUAL ${I_PM})

    # [pm_]list(INSERT)
    # ---------------
    set(TESTl_CM  A B E)
    set(TESTl_PM  A B E)

    list(INSERT    TESTl_CM  2  C D)
    pm_list(INSERT TESTl_PM  2  C D)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(REMOVE_ITEM)
    # ---------------
    set(TESTl_CM  1 2 3)
    set(TESTl_PM  1 2 3)

    list(REMOVE_ITEM    TESTl_CM 1 2)
    pm_list(REMOVE_ITEM TESTl_PM 1 2)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(REMOVE_AT)
    # ---------------
    set(TESTl_CM  1 2 3)
    set(TESTl_PM  1 2 3)

    list(REMOVE_AT    TESTl_CM 1 2)
    pm_list(REMOVE_AT TESTl_PM 1 2)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(REMOVE_DUPLICATES)
    # ---------------
    set(TESTl_CM  1 1 2 2 3)
    set(TESTl_PM  1 1 2 2 3)

    list(REMOVE_DUPLICATES    TESTl_CM)
    pm_list(REMOVE_DUPLICATES TESTl_PM)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(REVERSE)
    # ---------------
    set(TESTl_CM  1 1 2 2 3)
    set(TESTl_PM  1 1 2 2 3)

    list(REVERSE    TESTl_CM)
    pm_list(REVERSE TESTl_PM)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)

    # [pm_]list(SORT)
    # ---------------
    set(TESTl_CM  1 3 2 1 2)
    set(TESTl_PM  1 2 1 2 3)

    list(SORT    TESTl_CM)
    pm_list(SORT TESTl_PM)
    pm_list(COMPARE TESTl_CM TESTl_PM CMP)
    pm_fail(UNLESS ${CMP} EQUAL 0)


    message(STATUS "Running Postmodern List Test suite -- done")
endfunction()
