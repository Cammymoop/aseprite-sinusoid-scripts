
if not app.isUIAvailable then return end

local spr = app.sprite
if not spr then
    app.alert("No sprite found")
    return
end

function get_row_width(width, height, row_y)
    return math.ceil(width * math.sin(math.pi * (row_y + 0.5) / height))
end

local W = spr.width
local H = spr.height

app.transaction("Make Sinusoid Mask", function()
    local maskLayer = spr:newLayer()
    maskLayer.name = "Sinusoid Mask"
    maskLayer.isContinuous = true

    local cel = spr:newCel(maskLayer, 1)
    for i=1, #spr.frames do
        if i > 1 then
            spr:newCel(maskLayer, i, cel.image)
        end
    end
    local img = cel.image:clone()

    local maskColor = Color{ r=0, g=0, b=0 }
    local maskPixelColor = maskColor.rgbaPixel
    if spr.colorMode == ColorMode.GRAY then
        maskPixelColor = maskColor.grayPixel
    elseif spr.colorMode == ColorMode.INDEXED then
        maskPixelColor = maskColor.index
    end

    for y = 0, spr.height - 1 do
        local maskWidth = W - get_row_width(spr.width, spr.height, y)
        if maskWidth < 1 then goto continue end
        for i = 0, maskWidth - 1 do
            local x = i
            if x >= math.floor(maskWidth / 2.0) then x = x + W - maskWidth end
            img:drawPixel(x, y, maskPixelColor)
        end
        ::continue::
    end
    cel.image:drawImage(img)
end)



