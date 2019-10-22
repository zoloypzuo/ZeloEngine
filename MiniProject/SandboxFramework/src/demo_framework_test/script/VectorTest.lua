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

require "LuaTest"

local moduleName = "VectorTest";

LuaTest_AddTest(
    moduleName, "Addition1", function()
        local vector = Vector.new() + 2;
        
        AssertEqual(2, vector.x);
        AssertEqual(2, vector.y);
        AssertEqual(2, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Addition2", function()
        local vector = 2 + Vector.new();

        AssertNil(vector);
    end
);

LuaTest_AddTest(
    moduleName, "Addition3", function()
        local vector = Vector.new(1, 2, 3) + Vector.new(1, 2, 3);
        
        AssertEqual(2, vector.x);
        AssertEqual(4, vector.y);
        AssertEqual(6, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Assignment", function()
        local vector = Vector.new();
        
        vector.x = 10;
        vector.y = 5;
        vector.z = 1;
        
        AssertEqual(10, vector.x);
        AssertEqual(5, vector.y);
        AssertEqual(1, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Constructor1", function()
        local vector = Vector.new();
        
        AssertEqual(0, vector.x);
        AssertEqual(0, vector.y);
        AssertEqual(0, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Constructor2", function()
        local vector = Vector.new(10);
        
        AssertEqual(10, vector.x);
        AssertEqual(10, vector.y);
        AssertEqual(10, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Constructor3", function()
        local vector = Vector.new(1, 2, 3);
        
        AssertEqual(1, vector.x);
        AssertEqual(2, vector.y);
        AssertEqual(3, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "CopyConstructor", function()
        local expectedVector = Vector.new(10);
        local vector = Vector.new(expectedVector);
        
        AssertEqual(expectedVector.x, vector.x);
        AssertEqual(expectedVector.y, vector.y);
        AssertEqual(expectedVector.z, vector.z);
        AssertEqual(10, vector.x);
        AssertEqual(10, vector.y);
        AssertEqual(10, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Subtraction1", function()
        local vector = Vector.new(1, 2, 3) - 2;
        
        AssertEqual(-1, vector.x);
        AssertEqual(0, vector.y);
        AssertEqual(1, vector.z);
    end
);

LuaTest_AddTest(
    moduleName, "Subtraction2", function()
        local vector = 2 - Vector.new(1, 2, 3);
        
        AssertNil(vector);
    end
);

LuaTest_AddTest(
    moduleName, "Subtraction3", function()
        local vector = Vector.new(1, 2, 3) - Vector.new(5, 7, 1);
        
        AssertEqual(-4, vector.x);
        AssertEqual(-5, vector.y);
        AssertEqual(2, vector.z);
    end
);

function Sandbox_TestVector()
    local vector2Mul1 = vector2 * 2;
    local vector2Mul2 = vector2 * vector2;
    local vector2Mul3 = 2 * vector2;  -- should be nil
    
    local vector2Div1 = vector2 / 2;
    local veoctr2Div2 = vector2 / vector2;
    local vector2Div3 = 2 / vector2;  -- should be nil

    local vector2Neg1 = -vector2;
    
    local vector2Eq1 = vector2 == vector3;
    local vector2Eq2 = Vector.new(10) == vector2;
    local vector2Eq3 = vector4 == vector2;
    
    local vector2Neq1 = vector2 ~= vector3;
    local vector2Neq2 = Vector.new(10) ~= vector2;
    local vector2Neq3 = vector4 ~= vector2;
    
    local vector2String = tostring(vector2);
    return;
end
