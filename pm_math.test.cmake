# NB. We don't include_guard this file set; every time it's included, all tests
# should be allowed to run.

include(pm__core)
include(pm_math)   # system under test
include(pm_fail)   # required to fail the tests out

function(pm_run_math_tests)
    message(STATUS "Running Postmodern Math Test suite")

    pm_math(EXPR A "1 + 1")
    pm_fail(UNLESS ${A} EQUAL 2)

    pm_math(EXPR B "${A} * 2")
    pm_fail(UNLESS ${B} EQUAL 4)


    pm_math(MIN MIN_A 1)
    pm_fail(UNLESS ${MIN_A} EQUAL 1)
    pm_math(MIN MIN_B 1 2)
    pm_fail(UNLESS ${MIN_B} EQUAL 1)
    pm_math(MIN MIN_C 5 7 5 2 4)
    pm_fail(UNLESS ${MIN_C} EQUAL 2)


    pm_math(MAX MAX_A 1)
    pm_fail(UNLESS ${MAX_A} EQUAL 1)
    pm_math(MAX MAX_B 1 2)
    pm_fail(UNLESS ${MAX_B} EQUAL 2)
    pm_math(MAX MAX_C 5 7 5 2 4)
    pm_fail(UNLESS ${MAX_C} EQUAL 7)


    pm_math(IS_EVEN TEST_IS_EVEN 2)
    pm_fail(UNLESS TEST_IS_EVEN)
    pm_math(IS_EVEN TEST_IS_EVEN 1)
    pm_fail(IF     TEST_IS_EVEN)
    pm_math(IS_EVEN TEST_IS_EVEN 0)
    pm_fail(UNLESS TEST_IS_EVEN)
    pm_math(IS_EVEN TEST_IS_EVEN -1)
    pm_fail(IF     TEST_IS_EVEN)
    pm_math(IS_EVEN TEST_IS_EVEN -2)
    pm_fail(UNLESS TEST_IS_EVEN)


    pm_math(IS_ODD TEST_IS_ODD 2)
    pm_fail(IF     TEST_IS_ODD)
    pm_math(IS_ODD TEST_IS_ODD 1)
    pm_fail(UNLESS TEST_IS_ODD)
    pm_math(IS_ODD TEST_IS_ODD 0)
    pm_fail(IF     TEST_IS_ODD)
    pm_math(IS_ODD TEST_IS_ODD -1)
    pm_fail(UNLESS TEST_IS_ODD)
    pm_math(IS_ODD TEST_IS_ODD -2)
    pm_fail(IF     TEST_IS_ODD)


    set(V 1)
    pm_math(INCREMENT V)
    pm_fail(UNLESS ${V} EQUAL 2)
    pm_math(INCREMENT V)
    pm_fail(UNLESS ${V} EQUAL 3)

    pm_math(INCREMENT V OUTPUT W)
    pm_fail(UNLESS ${V} EQUAL 3)
    pm_fail(UNLESS ${W} EQUAL 4)

    pm_math(INCREMENT V BY 2)
    pm_fail(UNLESS ${V} EQUAL 5)
    pm_math(INCREMENT V BY 5)
    pm_fail(UNLESS ${V} EQUAL 10)

    pm_math(INCREMENT V BY 5 OUTPUT W)
    pm_fail(UNLESS ${V} EQUAL 10)
    pm_fail(UNLESS ${W} EQUAL 15)


    set(V 15)
    pm_math(DECREMENT V)
    pm_fail(UNLESS ${V} EQUAL 14)
    pm_math(DECREMENT V)
    pm_fail(UNLESS ${V} EQUAL 13)

    pm_math(DECREMENT V OUTPUT W)
    pm_fail(UNLESS ${V} EQUAL 13)
    pm_fail(UNLESS ${W} EQUAL 12)

    pm_math(DECREMENT V BY 2)
    pm_fail(UNLESS ${V} EQUAL 11)
    pm_math(DECREMENT V BY 5)
    pm_fail(UNLESS ${V} EQUAL 6)

    pm_math(DECREMENT V BY 5 OUTPUT W)
    pm_fail(UNLESS ${V} EQUAL 6)
    pm_fail(UNLESS ${W} EQUAL 1)


    set(V 7)
    pm_math(DOUBLE V)
    pm_fail(UNLESS ${V} EQUAL 14)
    pm_math(DOUBLE V)
    pm_fail(UNLESS ${V} EQUAL 28)

    pm_math(DOUBLE V OUTPUT W)
    pm_fail(UNLESS ${V} EQUAL 28)
    pm_fail(UNLESS ${W} EQUAL 56)


    set(V 56)
    pm_math(HALVE V)
    pm_fail(UNLESS ${V} EQUAL 28)
    pm_math(HALVE V)
    pm_fail(UNLESS ${V} EQUAL 14)

    pm_math(HALVE V OUTPUT W)
    pm_fail(UNLESS ${V} EQUAL 14)
    pm_fail(UNLESS ${W} EQUAL 7)


    message(STATUS "Running Postmodern Math Test suite -- done")
endfunction()

