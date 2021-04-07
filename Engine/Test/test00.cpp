// test00.cpp
// created on 2021/4/7
// author @zoloypzuo
//#include "ZeloPreCompiledHeader.h"
//#include "test00.h"
#include "gtest/gtest.h"
//#include "exp1.h"

int add(int a, int b) {
    return a + b;
}

namespace {
TEST(TestAdd, add) {
    ASSERT_EQ(3, add(1, 2));
}

TEST(Exp1Test, subtract) {
//double res;
//res = subtract_numbers(1.0, 2.0);
//ASSERT_NEAR(res, -1.0, 1.0e-11);
    ASSERT_EQ(1, 1);
}
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
