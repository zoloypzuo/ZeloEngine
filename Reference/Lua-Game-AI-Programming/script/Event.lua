-- Event.lua

---@class Event
---@field source string @comment event.source == "keyboard"
---@field pressed boolean
---@field key string @comment event.key == "space_key"
Event = {}

Event.source = nil

Event.pressed = nil

Event.key = nil

return Event
