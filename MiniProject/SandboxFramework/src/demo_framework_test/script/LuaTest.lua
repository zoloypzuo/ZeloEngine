--[[
  Copyright (c) 2013 David Young dayoung@goliathdesigns.com

  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]

local LuaTest = {};
LuaTest.tests = {};
LuaTest.currentTestResult = false;

local function PluralString(count, string)
    assert(type(count) == "number");
    if (count == 1) then
        return string;
    else
        return string .. "s";
    end
end

function AssertEqual(expected, actual)
    if (expected ~= actual) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s == %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(expected),
            tostring(actual)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertFalse(value)
    if (value) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(value)));
        print("  Actual: true");
        print("Expected: false");
    end
end

function AssertGreatThan(expected, actual)
    if (expected > actual) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s > %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(expected),
            tostring(actual)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertGreatThanEqual(expected, actual)
    if (expected >= actual) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s >= %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(expected),
            tostring(actual)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertLessThan(expected, actual)
    if (expected < actual) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s < %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(expected),
            tostring(actual)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertLessThanEqual(expected, actual)
    if (expected <= actual) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s <= %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(expected),
            tostring(actual)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertNil(value)
    if (value ~= nil) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s == nil",
            debugInfo.source,
            debugInfo.currentline,
            tostring(value)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertNotEqual(expected, actual)
    if (expected == actual) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s ~= %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(expected),
            tostring(actual)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertNotNil(value)
    if (value == nil) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: %s ~= nil",
            debugInfo.source,
            debugInfo.currentline,
            tostring(value)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function AssertTrue(value)
    if (not value) then
        LuaTest.currentTestResult = false;
        local debugInfo = debug.getinfo(2);
        print(string.format(
            "%s(%d): error: Value of: not %s",
            debugInfo.source,
            debugInfo.currentline,
            tostring(value)));
        print("  Actual: false");
        print("Expected: true");
    end
end

function LuaTest_AddTest(unitTestModule, unitTestName, unitTestFunction)
    if (LuaTest.tests[unitTestModule] == nil) then
        LuaTest.tests[unitTestModule] = {};
    end
    
    local module = LuaTest.tests[unitTestModule];

    -- Make sure the same test doesn't already exist.
    assert(module[unitTestName] == nil);
    module[unitTestName] = unitTestFunction;
end

function LuaTest_NumberOfTestModules()
    local moduleCount = 0;
    
    for moduleName, moduleTable in pairs(LuaTest.tests) do
        moduleCount = moduleCount + 1;
    end
    
    return moduleCount;
end

function LuaTest_NumberOfTests(moduleName)
    local testCount = 0;
    
    if (moduleName == nil) then
        for moduleName, moduleTable in pairs(LuaTest.tests) do
            for unitTestName, unitTestFunction in pairs(moduleTable) do
                testCount = testCount + 1;
            end
        end
    else
        for unitTestName, unitTestFunction in pairs(LuaTest.tests[moduleName]) do
            testCount = testCount + 1;
        end
    end
    
    return testCount;
end

function LuaTest_PrintFooter(totalTime)
    local numberOfTestModules = LuaTest_NumberOfTestModules();
    local numberOfTests = LuaTest_NumberOfTests();
    
    print("[----------] Global test environment tear-down");
    print(string.format(
        "[==========] %d %s from %d test %s run. (%d ms total)",
        numberOfTests,
        PluralString(numberOfTests, "test"),
        numberOfTestModules,
        PluralString(numberOfTestModules, "case"),
        totalTime));
end

function LuaTest_PrintHeader()
    local numberOfTestModules = LuaTest_NumberOfTestModules();
    local numberOfTests = LuaTest_NumberOfTests();
    
    print(string.format(
        "[==========] Running %d %s from %d test %s.",
        numberOfTests,
        PluralString(numberOfTests, "test"),
        numberOfTestModules,
        PluralString(numberOfTestModules, "case")));
    print("[----------] Global test environment set-up.");
end

function LuaTest_PrintModuleFoot(moduleName, totalModuleTime)
    local testCount = LuaTest_NumberOfTests(moduleName);

    print(string.format(
        "[----------] %d %s from %s (%d ms total)\n",
        testCount,
        PluralString(testCount, "test"),
        moduleName,
        totalModuleTime));
end

function LuaTest_PrintModuleHeader(moduleName)
    local testCount = LuaTest_NumberOfTests(moduleName);
    
    print(string.format(
        "[----------] %d %s from %s",
        testCount,
        PluralString(testCount, "test"),
        moduleName));
end

function LuaTest_PrintSummary(passedTests, failedTests)
    print(string.format(
        "[  PASSED  ] %d %s.",
        #passedTests,
        PluralString(#passedTests, "test")));
    
    if (#failedTests > 0) then
        print(string.format(
            "[  FAILED  ] %d %s, listed below:",
            #failedTests,
            PluralString(#failedTests, "test")));

        for key, testName in pairs(failedTests) do
            print(string.format("[  FAILED  ] %s", testName));
        end

        print(string.format("\n%d FAILED TEST", #failedTests));
    end
end

function LuaTest_PrintTestInfo(testName)
    print(string.format("[ RUN      ] %s", testName));
end

function LuaTest_PrintTestResult(testResult, testName, testTime)
    if (testResult) then
        print(string.format("[       OK ] %s (%d ms)", testName, testTime));
    else
        print(string.format("[  FAILED  ] %s (%d ms)", testName, testTime));
    end
end

function LuaTest_RunTests()
    local passedTests = {};
    local failedTests = {};
    
    local startTime = os.clock();
    
    LuaTest_PrintHeader();

    for moduleName, moduleTable in pairs(LuaTest.tests) do
        local moduleStartTime = os.clock();
        
        LuaTest_PrintModuleHeader(moduleName);
        
        -- Sort unit tests based on the test name.
        local sortedTestNames = {};
        
        for key in pairs(moduleTable) do
            table.insert(sortedTestNames, key);
        end
        
        table.sort(sortedTestNames);

        for index, unitTestName in ipairs(sortedTestNames) do
            local unitTestFunction = moduleTable[unitTestName];
        
            local testStartTime = os.clock();
            local testName = moduleName .. "." .. unitTestName;

            currentTest = testName;
            LuaTest.currentTestResult = true;

            LuaTest_PrintTestInfo(testName);

            -- Run unit test.
            unitTestFunction();

            if (LuaTest.currentTestResult) then
                table.insert(passedTests, testName);
            else
                table.insert(failedTests, testName);
            end
            
            local totalTestTime = os.clock() - testStartTime;
            
            LuaTest_PrintTestResult(LuaTest.currentTestResult, testName, totalTestTime * 1000);
        end
        
        local totalModuleTime = os.clock() - moduleStartTime;
        
        LuaTest_PrintModuleFoot(moduleName, totalModuleTime * 1000);
    end
    
    local totalTime = os.clock() - startTime;
    
    LuaTest_PrintFooter(totalTime * 1000);
    LuaTest_PrintSummary(passedTests, failedTests);
    
    if (#failedTests > 0) then
        os.exit(-1);
    end
    os.exit(0);
end
