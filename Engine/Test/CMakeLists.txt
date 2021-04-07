# created on 2021/4/7
# author @zoloypzuo
# Now simply link against gtest or gtest_main as needed. Eg
add_executable(
        test00
        test00.cpp
)

target_link_libraries(test00
        PRIVATE
        GTest::gmock
        GTest::gtest
        GTest::gmock_main
        GTest::gtest_main)
#target_link_libraries(
#        test00
#        gtest_main
#        libexample
#)

add_test(
        NAME
        test00
        COMMAND
        $<TARGET_FILE:test00>
)
