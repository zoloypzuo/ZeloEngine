-- main_function
-- created on 2021/8/6
-- author @zoloypzuo

function initialize()
    print("initialize")
    print("=== Start Test sol2")
    do
        print("=== Entity")
        TheSim = Game.GetSingletonPtr()
        local e = TheSim:CreateEntity()
    end
    print("=== End Test sol2")
end

function finalize()
    print("finalize")
end

function update()
    --print("update")
end