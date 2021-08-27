# Drag and Drop

TODO 目前这个被Hierarchy和AssetBrowser引用，涉及userdata，暂时不做了

![](https://user-images.githubusercontent.com/1795930/42392543-8140fc1e-8153-11e8-8f15-6c4da5521508.gif)

写法：
* 每个Button是可拖拽的，Button调用后跟着Begin/EndDD调用

```lua
butnum = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
for i = 0, 15 do
    ig.Button("but" .. butnum[i], ig.ImVec2(50, 50))
    if ig.BeginDragDropSource() then
        anchor.data = ffi.new("int[1]", i)
        ig.SetDragDropPayload("ITEMN", anchor.data, ffi.sizeof "int", C.ImGuiCond_Once);
        ig.Button("drag" .. butnum[i], ig.ImVec2(50, 50));
        ig.EndDragDropSource();
    end
    if ig.BeginDragDropTarget() then
        local payload = ig.AcceptDragDropPayload("ITEMN")
        if (payload ~= nil) then
            assert(payload.DataSize == ffi.sizeof "int");
            local numptr = ffi.cast("int*", payload.Data)
            --swap numbers
            butnum[numptr[0]], butnum[i] = butnum[i], butnum[numptr[0]]
        end
        ig.EndDragDropTarget();
    end
    if ((i % 4) < 3) then
        ig.SameLine()
    end
end
```