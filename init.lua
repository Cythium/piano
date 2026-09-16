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

-- Generate the Custom Formspec Grid
local function get_sky_formspec()
    local fs = "formspec_version[4]" .. -- Enforce precise scaling coords across all screens
               "size[11.0, 7.5]" ..
               "bgcolor[#0d1117cc;true]" .. -- Translucent dark slate background
               
               -- Strip native blocky UI borders to create a clean minimalist touch-pad look
               "style_type[image_button;border=false;content_margin=0]"

    -- Positioning Parameters
    local start_x = 1.2
    local start_y = 1.0
    local size_w  = 1.4
    local size_h  = 1.4
    local spacing = 0.3 -- Layout spacing between pads

    for _, note in ipairs(sky_notes) do
        local x = start_x + (note.col * (size_w + spacing))
        local y = start_y + (note.row * (size_h + spacing))
        
        -- Append individual instrument key button
        fs = fs .. string.format(
            "image_button[%f,%f;%f,%f;%s;sky_%d;;false;false;sky_icon_pressed.png]",
            x, y, size_w, size_h, note.texture, note.id
        )
    end
    return fs
end

-- Register the Instrument Block Node
minetest.register_node("piano:sky_instrument", {
    description = "Sky CoTL Diatonic Instrument Pad",
    tiles = {"default_gold_block.png"}, -- Node fallback texture (change to your mod's blocks)
    groups = {oddly_breakable_by_hand = 3, cracky = 3},
    
    on_rightclick = function(pos, node, clicker)
        if not clicker or not clicker:is_player() then return end
        minetest.show_formspec(clicker:get_player_name(), "piano:sky_ui", get_sky_formspec())
    end,
})

-- Process Real-time Player Note Triggers
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "piano:sky_ui" then return false end
    if fields.quit then return true end -- Exit safely if player closes interface

    -- Scan for the clicked note ID
    for i = 1, 15 do
        if fields["sky_" .. i] then
            local p_name = player:get_player_name()
            local pos = player:get_pos()
            
            -- Play the corresponding authentic sound asset
            minetest.sound_play("sky_note_" .. i, {
                pos = pos,
                gain = 0.8,
                max_hear_distance = 16,
                pitch = 1.0, -- Flat mapping since audio inputs are natively pre-tuned
            }, true)

            -- Instantly refresh the UI container to handle uninterrupted continuous jamming
            minetest.show_formspec(p_name, "piano:sky_ui", get_sky_formspec())
            return true
        end
    end
    return true
end)
