-- Sky CoTL 3x5 Grid Layout Mapping
-- The pitch increases left-to-right, top-to-bottom.
local sky_notes = {
    -- Top Row (Notes 1 - 5): Low/Bass Octave
    { id = 1, row = 0, col = 0, texture = "sky_icon_circle.png" },
    { id = 2, row = 0, col = 1, texture = "sky_icon_circle.png" },
    { id = 3, row = 0, col = 2, texture = "sky_icon_diamond.png" }, -- Root C accent key
    { id = 4, row = 0, col = 3, texture = "sky_icon_circle.png" },
    { id = 5, row = 0, col = 4, texture = "sky_icon_circle.png" },

    -- Middle Row (Notes 6 - 10): Mid Octave
    { id = 6,  row = 1, col = 0, texture = "sky_icon_circle.png" },
    { id = 7,  row = 1, col = 1, texture = "sky_icon_circle.png" },
    { id = 8,  row = 1, col = 2, texture = "sky_icon_diamond.png" }, -- Root C accent key
    { id = 9,  row = 1, col = 3, texture = "sky_icon_circle.png" },
    { id = 10, row = 1, col = 4, texture = "sky_icon_circle.png" },

    -- Bottom Row (Notes 11 - 15): High Octave
    { id = 11, row = 2, col = 0, texture = "sky_icon_circle.png" },
    { id = 12, row = 2, col = 1, texture = "sky_icon_circle.png" },
    { id = 13, row = 2, col = 2, texture = "sky_icon_diamond.png" }, -- Root C accent key
    { id = 14, row = 2, col = 3, texture = "sky_icon_circle.png" },
    { id = 15, row = 2, col = 4, texture = "sky_icon_circle.png" },
}

-- Pre-cache the formspec string during load time so it isn't rebuilt on every right-click
local cached_sky_formspec = ""
local function cache_sky_formspec()
    local fs = "formspec_version[4]" ..
               "size[11.0, 7.5]" ..
	       "no_prepend[]" ..
	       "bgcolor[;neither;]" ..
               -- "bgcolor[#0d1117cc;true]" ..
               "style_type[image_button;border=false;content_margin=0]"

    local start_x = 1.2
    local start_y = 1.0
    local size_w  = 1.4
    local size_h  = 1.4
    local spacing = 0.3

    for _, note in ipairs(sky_notes) do
        local x = start_x + (note.col * (size_w + spacing))
        local y = start_y + (note.row * (size_h + spacing))
        
        fs = fs .. string.format(
            "image_button[%f,%f;%f,%f;%s;sky_%d;;false;false;sky_icon_pressed.png]",
            x, y, size_w, size_h, note.texture, note.id
        )
    end
    cached_sky_formspec = fs
end
cache_sky_formspec() -- Run once at load

-- Register the Instrument Block Node
minetest.register_node("piano:sky_instrument", {
    description = "Sky CoTL Diatonic Instrument Pad",
    tiles = {"default_gold_block.png"}, 
    groups = {oddly_breakable_by_hand = 3, cracky = 3},
    
    on_rightclick = function(pos, node, clicker)
        if not clicker or not clicker:is_player() then return end
        minetest.show_formspec(clicker:get_player_name(), "piano:sky_ui", cached_sky_formspec)
    end,
})

-- Process Real-time Player Note Triggers (Optimized)
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "piano:sky_ui" then return false end
    if fields.quit then return true end 

    -- O(1) Instant Direct Lookup Strategy
    for field_name, _ in pairs(fields) do
        -- Check if the field starts with "sky_"
        if string.sub(field_name, 1, 4) == "sky_" then
            -- Safely extract the note ID number
            local note_id = tonumber(string.sub(field_name, 5))
            
            if note_id and note_id >= 1 and note_id <= 15 then
                -- Play the sound instantly at the player's current location
                minetest.sound_play("sky_note_" .. note_id, {
                    pos = player:get_pos(),
                    gain = 0.8,
                    max_hear_distance = 16,
                    pitch = 1.0,
                }, true)
                
                return true -- Finished handling input safely
            end
        end
    end
    return true
end)
