-------------------------------------------------------------------------------
--[[WIRE TOOLS]]--
-------------------------------------------------------------------------------
local Player = require("stdlib.event.player")
local lib = require("picker.lib")

--Cut wires code modified from "WireStripper", by "justarandomgeek"
--https://mods.factorio.com/mods/justarandomgeek/wirestripper
local function cut_wires(event)
    local player = Player.get(event.player_index)
    if player.admin and player.selected and player.selected.circuit_connected_entities then
        local a, b, c
        a = pcall(function() player.selected.disconnect_neighbour() end)
        b = pcall(function() player.selected.disconnect_neighbour(defines.wire_type.red) end)
        c = pcall(function() player.selected.disconnect_neighbour(defines.wire_type.green) end)
        if a or b or c then
            player.print({"wiretool.all-wires-removed"})
            if player.selected.last_user then player.selected.last_user = player end
        end
    end
end
Event.register("picker-wire-cutter", cut_wires)

local wire_types = {
    "red-wire",
    "green-wire",
    "copper-cable",
}

local function pick_wires(event)
    local player = Player.get(event.player_index)
    local stack = player.cursor_stack
    if not stack.valid_for_read then
        for _, wire_name in ipairs (wire_types) do
            local wire = lib.get_item_stack(player, wire_name)
            if wire then
                stack.set_stack(wire)
                wire.clear()
                return
            end
        end
        player.print({"wiretool.no-wires-found"})
    elseif stack.valid_for_read then
        local index
        local _find = function(v, k)
            if v == stack.name then
                index = k
                return true
            end
        end

        if table.any(wire_types, _find) then
            local start = index
            repeat
                index = index < #wire_types and index + 1 or 1
                local wire = lib.get_item_stack(player, wire_types[index])
                if wire then
                    return player.clean_cursor() and stack.set_stack(wire) and wire.clear()
                end
            until index == start
            player.print({"wiretool.no-wires-found"})
            player.clean_cursor()
        end
    end
end
Event.register("picker-wire-picker", pick_wires)
