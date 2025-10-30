
if not app.isUIAvailable then return end

local currentAngle = 5000
local resetOnClose = true

local cDialog = nil

function update_rotation_amount()
    local old_rotation = currentAngle
    currentAngle = cDialog.data.rotationAmount

    change_image_rotation(old_rotation)
end

function reset()
    cDialog:modify{id="rotationAmount", value=5000}
    update_rotation_amount()
end

cDialog = Dialog{
    title="Sinusoidal Texture Rotator",
    onclose=reset
}

cDialog:slider{
    id="rotationAmount",
    label="Rotation",
    min=0,
    max=10000,
    value=currentAngle,
    onchange=update_rotation_amount
}
cDialog:button{
    id="resetButton",
    text="Reset to Center",
    onclick=reset
}
cDialog:check{
    id="resetOnClose",
    text="Reset on close",
    selected=resetOnClose
}

function get_cel()
    local spr = app.sprite
    if not spr then
        app.alert("No active sprite found")
        return
    end

    local cel = app.cel
    if not cel or not cel.image then
        app.alert("Active cel is not an image")
        return
    end
    return cel
end

function change_image_rotation(from_a)
    local cel = get_cel()
    if not cel then return end
    
    local new_img = cel.image:clone()
    
    local H = app.sprite.height
    local W = app.sprite.width
    
    local old_discrete = math.ceil((from_a / 10000.0) * W - 0.5)
    local new_discrete = math.ceil((currentAngle / 10000.0) * W - 0.5)
    
    if old_discrete == new_discrete then return end
    
    for row_y = 0, H - 1 do
        local rWidth = get_row_width(W, H, row_y)
        local base_x = W/2.0 + 0.25
        local delta_rotated = math.ceil(new_discrete / W * rWidth - 0.5) - math.ceil(old_discrete / W * rWidth - 0.5)
        for pixel_i = 0, rWidth - 1 do
            local new_i = (pixel_i + delta_rotated) % rWidth
            local old_x = math.floor(base_x + pixel_i - rWidth/2.0)
            local new_x = math.floor(base_x + new_i - rWidth/2.0)
            new_img:drawPixel(new_x, row_y, cel.image:getPixel(old_x, row_y))
        end
    end
    cel.image:drawImage(new_img)
    app.refresh()
end

function get_row_width(width, height, row_y)
    return math.ceil(width * math.sin(math.pi * (row_y + 0.5) / height))
end

cDialog:show{ wait=false }
