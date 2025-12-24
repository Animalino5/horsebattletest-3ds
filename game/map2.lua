map2 = {}

local chest2, chestW2, chestH2
local chests2 = {}
local x2_1, y2_1, x2_2, y2_2
local speedX2_1, speedY2_1, speedX2_2, speedY2_2

local zoom2, balltimer2_1, balltimer2_2, isballshown2
local chestcount2_h1, chestcount2_h2

local obstacle2, mapData2, mapW2, mapH2
local logo2_1, logo2_2, logo2W, logo2H
local solidPixels2 = {}
local logo2W, logo2H = 16, 16
local chestW2, chestH2 = 16, 16

local savedMag1 = 150 
local speedGain = 25

local function map2_isBlackPixel(x, y)
    local ix, iy = math.floor(x), math.floor(y)
    if ix < 0 or iy < 0 or ix >= mapW2 or iy >= mapH2 then return true end
    return solidPixels2[ix] and solidPixels2[ix][iy] == true
end

local function map2_findValidChestPosition()
    local attempts = 0
    while attempts < 1000 do
        local rx = love.math.random(0, mapW2 - (chestW2 or 16))
        local ry = love.math.random(0, mapH2 - (chestH2 or 16))
        if not map2_isBlackPixel(rx + 8, ry + 8) then return rx, ry end
        attempts = attempts + 1
    end
    return 200, 200
end

local playerSensors = {
    {x = 0, y = 0}, {x = 8, y = 0}, {x = 15, y = 0}, 
    {x = 0, y = 15}, {x = 8, y = 15}, {x = 15, y = 15}, 
    {x = 0, y = 8}, {x = 15, y = 8} 
}
local bumpTimer2 = 0

local function map2_spawnChests(n)
    chests2 = {}
    for i = 1, n do
        local cx, cy = map2_findValidChestPosition()
        table.insert(chests2, {x = cx, y = cy})
    end
end

local function map2_findNearestChest(x, y)
    if #chests2 == 0 then return nil, nil end
    local bestDx, bestDy, bestDist = 0, 0, math.huge
    for _, c in ipairs(chests2) do
        local dx, dy = (c.x + 8) - x, (c.y + 8) - y
        local dist = dx*dx + dy*dy
        if dist < bestDist then
            bestDist = dist
            bestDx, bestDy = dx, dy
        end
    end
    return bestDx, bestDy
end

local function map2_checkInput()
    local touches = love.touch.getTouches()
    if #touches > 0 then
        local id = touches[1]
        local tx, ty = love.touch.getPosition(id)
        return true, tx, ty
    end
    return false
end

function map2.setDirection(dx, dy, isPlayer)
    local len = math.sqrt(dx*dx + dy*dy)
    if len < 5 then return end 

    if isPlayer then
        local normX, normY = dx / len, dy / len
        speedX2_1 = normX * savedMag1
        speedY2_1 = normY * savedMag1
        isballshown2 = false
        balltimer2_1 = 0
    else
        local currentMag = math.sqrt(speedX2_2^2 + speedY2_2^2)
        if currentMag < 50 then currentMag = 120 end
        speedX2_2 = (dx / len) * currentMag
        speedY2_2 = (dy / len) * currentMag
    end
end

local function allChestsEaten2()
    if chestcount2_h1 > chestcount2_h2 then 
        whowon = "or" 
        if gameMode == "classic" then 
            isNewRecord = checkAndSaveScore(currentRoom, timer) 
        else
            isNewRecord = checkAndSaveScore(currentRoom, chestcount2_h1) 
        end
    elseif chestcount2_h1 < chestcount2_h2 then 
        whowon = "bl" 
    else
        whowon = "tie"
    end
    if not isFading then startFade("win") end
end

function map2.loadRoom()
    logo2_1 = love.graphics.newImage("ASSETS/horseplayer1.png")
    logo2_2 = love.graphics.newImage("ASSETS/horseplayer2.png")
    chest2 = love.graphics.newImage("ASSETS/chest.png")
    
    obstacle2 = love.graphics.newImage("ASSETS/map2collision.png")
    
    local tempData = love.image.newImageData("ASSETS/map2collision.png")
    mapW2, mapH2 = tempData:getDimensions()

    solidPixels2 = {}
    for ty = 0, mapH2 - 1 do
        for tx = 0, mapW2 - 1 do
            local r, g, b = tempData:getPixel(tx, ty)
            if r < 0.1 and g < 0.1 and b < 0.1 then
                -- Store as a string key or a nested table
                if not solidPixels2[tx] then solidPixels2[tx] = {} end
                solidPixels2[tx][ty] = true
            end
        end
    end

    tempData = nil
    collectgarbage("collect")

    bumpsnd = love.audio.newSource("ASSETS/bump.wav", "static")
    chestsnd = love.audio.newSource("ASSETS/chest.wav", "static")

    map2.resetRoom()
end

function map2.updateRoom(dt)
    if not isFading then
        if gameMode == "timetrial" then
            timer = timer - dt
            if timer <= 0 then timer = 0; allChestsEaten2() end
        else
            timer = timer + dt
        end
    end

    balltimer2_1 = balltimer2_1 + dt
    if bumpTimer2 > 0 then bumpTimer2 = bumpTimer2 - dt end
    
    local pad = love.joystick.getJoysticks()[1]
    if pad then
        if pad:isGamepadDown("dpup") then zoom2 = math.min(zoom2 + 1.0 * dt, 2.0) end
        if pad:isGamepadDown("dpdown") then zoom2 = math.max(zoom2 - 1.0 * dt, 1.0) end
    end 

    if (not isballshown2) and balltimer2_1 >= 3 then
        isballshown2 = true
        savedMag1 = math.sqrt(speedX2_1^2 + speedY2_1^2)
        if savedMag1 < 50 then savedMag1 = 150 end
        speedX2_1, speedY2_1 = 0, 0
    end

    if isballshown2 then
        local clicked, bx, by = map2_checkInput()
        if clicked then
            local cx, cy = 160, 130
            map2.setDirection(bx - cx, by - cy, true)
        end
    end

    if not isballshown2 then
        balltimer2_2 = balltimer2_2 + dt
        if balltimer2_2 >= 4 then
            balltimer2_2 = 0
local tDx, tDy = map2_findNearestChest(x2_2 + logo2W/2, y2_2 + logo2H/2)
if tDx then map2.setDirection(tDx, tDy, false) end
        end

        local dx = (x2_1 + logo2W/2) - (x2_2 + logo2W/2)
        local dy = (y2_1 + logo2H/2) - (y2_2 + logo2H/2)
        local dist = math.sqrt(dx*dx + dy*dy)
        local minDist = 16 

        if dist < minDist then
            speedX2_1, speedX2_2 = speedX2_2, speedX2_1
            speedY2_1, speedY2_2 = speedY2_2, speedY2_1
            local push = (minDist - dist) / 2
            local nx, ny = dx/dist, dy/dist
            x2_1, y2_1 = x2_1 + nx*push, y2_1 + ny*push
            x2_2, y2_2 = x2_2 - nx*push, y2_2 - ny*push
            if bumpTimer2 <= 0 then bumpsnd:stop(); bumpsnd:play(); bumpTimer2 = 0.1 end
        end

        local oldX1, oldY1 = x2_1, y2_1
        x2_1 = x2_1 + speedX2_1 * dt
        for _, p in ipairs(playerSensors) do
            if map2_isBlackPixel(x2_1 + p.x, y2_1 + p.y) then x2_1 = oldX1; speedX2_1 = -speedX2_1; break end
        end
        y2_1 = y2_1 + speedY2_1 * dt
        for _, p in ipairs(playerSensors) do
            if map2_isBlackPixel(x2_1 + p.x, y2_1 + p.y) then y2_1 = oldY1; speedY2_1 = -speedY2_1; break end
        end

        local oldX2, oldY2 = x2_2, y2_2
        x2_2 = x2_2 + speedX2_2 * dt
        for _, p in ipairs(playerSensors) do
            if map2_isBlackPixel(x2_2 + p.x, y2_2 + p.y) then x2_2 = oldX2; speedX2_2 = -speedX2_2; break end
        end
        y2_2 = y2_2 + speedY2_2 * dt
        for _, p in ipairs(playerSensors) do
            if map2_isBlackPixel(x2_2 + p.x, y2_2 + p.y) then y2_2 = oldY2; speedY2_2 = -speedY2_2; break end
        end
    end

    for i = #chests2, 1, -1 do
        local c = chests2[i]

        if x2_1 < c.x + chestW2 and x2_1 + logo2W > c.x and y2_1 < c.y + chestH2 and y2_1 + logo2H > c.y then
            table.remove(chests2, i)
            chestcount2_h1 = chestcount2_h1 + 1
            chestsnd:stop(); chestsnd:play()
            
            local curMag = math.sqrt(speedX2_1^2 + speedY2_1^2)
            if curMag == 0 then curMag = savedMag1 end 
            speedX2_1, speedY2_1 = (speedX2_1/curMag) * (curMag+speedGain), (speedY2_1/curMag) * (curMag+speedGain)
            savedMag1 = curMag + speedGain
            
            if gameMode == "timetrial" then
                local rx, ry = map2_findValidChestPosition()
                table.insert(chests2, {x = rx, y = ry})
            end

        elseif x2_2 < c.x + chestW2 and x2_2 + logo2W > c.x and y2_2 < c.y + chestH2 and y2_2 + logo2H > c.y then
            table.remove(chests2, i)
            chestcount2_h2 = chestcount2_h2 + 1
            chestsnd:stop(); chestsnd:play()

            local curMag = math.sqrt(speedX2_2^2 + speedY2_2^2)
            if curMag > 0 then
                speedX2_2, speedY2_2 = (speedX2_2/curMag) * (curMag+speedGain), (speedY2_2/curMag) * (curMag+speedGain)
            end

            if gameMode == "timetrial" then
                local rx, ry = map2_findValidChestPosition()
                table.insert(chests2, {x = rx, y = ry})
            end
        end
    end

    if gameMode == "classic" and #chests2 == 0 and not isFading then allChestsEaten2() end
end

function map2.drawRoom()
    local viewW, viewH = TOP_W / zoom2, TOP_H / zoom2
    local camX = math.max(0, math.min(x2_1 - viewW/2, mapW2 - viewW))
    local camY = math.max(0, math.min(y2_1 - viewH/2, mapH2 - viewH))

    love.graphics.push()
    love.graphics.scale(zoom2, zoom2)
    love.graphics.translate(-camX, -camY)
    love.graphics.draw(obstacle2, 0, 0)
    for _, c in ipairs(chests2) do love.graphics.draw(chest2, c.x, c.y) end
    love.graphics.draw(logo2_1, x2_1, y2_1)
    love.graphics.draw(logo2_2, x2_2, y2_2)
    love.graphics.pop()
end

function map2.drawBottomRoom()
    if bottomBG then love.graphics.draw(bottomBG, 0, 0) end
    if isballshown2 then love.graphics.draw(dirCir, 120, 90) end

    love.graphics.setColor(0,0,0)
    
    if gameMode == "timetrial" then
        local mins, secs = math.floor(timer/60), math.floor(timer%60)
        local ms = math.floor((timer*1000)%1000)
        
        love.graphics.print(string.format("TIME LEFT: %02d:%02d:%03d", mins, secs, ms), 5, 5)
        love.graphics.print("ORANGE: " .. chestcount2_h1, 10, 30)
        love.graphics.print("BLUE: " .. chestcount2_h2, 10, 50)
    else
        local mins, secs = math.floor(timer/60), math.floor(timer%60)
        local ms = math.floor((timer*1000)%1000)
        love.graphics.print(string.format("TIME: %02d:%02d:%03d", mins, secs, ms), 5, 5)
    end
    
    love.graphics.setColor(1,1,1)
end

function map2.resetRoom()
    x2_1, y2_1 = 207, 41
    x2_2, y2_2 = 207, 77
    speedX2_1, speedY2_1 = 100, 100
    speedX2_2, speedY2_2 = 100, 100
    savedMag1 = 150
    zoom2, balltimer2_1, balltimer2_2 = 1.6, 0, 0
    isballshown2, chestcount2_h1, chestcount2_h2 = false, 0, 0
    if gameMode == "classic" then timer = 0 end
    map2_spawnChests(9)
end

function map2.unload()
    obstacle2 = nil
    mapData2 = nil
   solidPixels2 = {}
collectgarbage("collect")

end
