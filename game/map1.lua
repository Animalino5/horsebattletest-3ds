local chest, chestW, chestH
local chests = {}
local logo, logo2, logoW, logoH, logo2W, logo2H
local x, y, x2, y2
local speedX, speedY, speedX2, speedY2
local zoom, balltimer, balltimer2, isballshown
local chestcount_h1, chestcount_h2
local obstacle, mapData, mapW, mapH
local solidPixels = {}
local solidPixels2 = {}
local logoW, logoH = 16, 16
local logo2W, logo2H = 16, 16
local chestW, chestH = 16, 16

local savedMag1 = 150 
local speedGain = 25 

local playerSensors = {
    {x = 0, y = 0}, {x = 8, y = 0}, {x = 15, y = 0},
    {x = 0, y = 15}, {x = 8, y = 15}, {x = 15, y = 15}, 
    {x = 0, y = 8}, {x = 15, y = 8} 
}

local bumpTimer = 0 

local function isBlackPixel(px, py)
    local ix, iy = math.floor(px), math.floor(py)
    if ix < 0 or iy < 0 or ix >= mapW or iy >= mapH then return true end
    return solidPixels[ix] and solidPixels[ix][iy] == true
end

local function findValidChestPosition()
    local attempts = 0
    while attempts < 1000 do
        local rx = love.math.random(0, mapW - 16)
        local ry = love.math.random(0, mapH - 16)
        if not isBlackPixel(rx + 8, ry + 8) then 
            return rx, ry 
        end
        attempts = attempts + 1
    end
    return 100, 100
end

function spawnChests(n)
    chests = {}
    for i = 1, n do
        local cx, cy = findValidChestPosition()
        table.insert(chests, {x = cx, y = cy})
    end
end

local function findNearestChest(targetX, targetY)
    if #chests == 0 then return nil, nil end
    local bestDx, bestDy, bestDist = 0, 0, math.huge
    for _, c in ipairs(chests) do
        local dx = (c.x + 8) - targetX
        local dy = (c.y + 8) - targetY
        local dist = dx*dx + dy*dy
        if dist < bestDist then
            bestDist = dist
            bestDx, bestDy = dx, dy
        end
    end
    return bestDx, bestDy
end
local function checkBottomClick()
    local touches = love.touch.getTouches()
    if #touches > 0 then
        local id = touches[1]
        local tx, ty = love.touch.getPosition(id)
        return true, tx, ty
    end
    
    return false
end

function map1_setDirection(dx, dy, isPlayer)
    local len = math.sqrt(dx*dx + dy*dy)
    if len < 5 then return end 

    if isPlayer then
        local normX, normY = dx / len, dy / len
        speedX = normX * savedMag1
        speedY = normY * savedMag1
        isballshown = false
        balltimer = 0
    else
        local curMag = math.sqrt(speedX2^2 + speedY2^2)
        if curMag < 50 then curMag = 120 end
        speedX2 = (dx / len) * curMag
        speedY2 = (dy / len) * curMag
    end
end

local function allChestsEaten()
    if chestcount_h1 > chestcount_h2 then 
        whowon = "or" 
        if gameMode == "classic" then 
            isNewRecord = checkAndSaveScore(currentRoom, timer) 
        else
            isNewRecord = checkAndSaveScore(currentRoom, chestcount_h1) 
        end
    elseif chestcount_h1 < chestcount_h2 then 
        whowon = "bl" 
    else
        whowon = "tie"
    end
    if not isFading then startFade("win") end
end

function map1_loadRoom()
    logo = love.graphics.newImage("assets/horseplayer1.png")
    logo2 = love.graphics.newImage("assets/horseplayer2.png")
    chest = love.graphics.newImage("assets/chest.png")
    
    obstacle = love.graphics.newImage("assets/mapcollision.png")
    local tempMapData = love.image.newImageData("assets/mapcollision.png")
    mapW, mapH = tempMapData:getDimensions()

solidPixels = {}
    for ty = 0, mapH - 1 do
        for tx = 0, mapW - 1 do
            local r, g, b = tempMapData:getPixel(tx, ty)
            -- If it's black (collision)
            if r < 0.1 and g < 0.1 and b < 0.1 then
                solidPixels[tx] = solidPixels[tx] or {}
                solidPixels[tx][ty] = true
            end
        end
    end

    tempMapData = nil
    collectgarbage("collect")

    bumpsnd = love.audio.newSource("assets/bump.wav", "static")
    chestsnd = love.audio.newSource("assets/chest.wav", "static")

    map1_resetRoom()
end

function map1_updateRoom(dt)
        if gameMode == "timetrial" then
            timer = timer - dt  
            if timer <= 0 then 
                timer = 0
                allChestsEaten() 
            end
        else
            timer = timer + dt  
        end

    balltimer = balltimer + dt
    if bumpTimer > 0 then bumpTimer = bumpTimer - dt end

    local joysticks = love.joystick.getJoysticks()
    if joysticks[1] then
        local pad = joysticks[1]
        if pad:isGamepadDown("dpup") then zoom = math.min(zoom + 1.0 * dt, 2.0) end
        if pad:isGamepadDown("dpdown") then zoom = math.max(zoom - 1.0 * dt, 1.0) end
    end

    if (not isballshown) and balltimer >= 3 then
        isballshown = true
        savedMag1 = math.sqrt(speedX^2 + speedY^2)
        if savedMag1 < 50 then savedMag1 = 150 end
        speedX, speedY = 0, 0
    end

    if isballshown then
        local clicked, bx, by = checkBottomClick()
        if clicked then
            local cx, cy = 160, 130
            map1_setDirection(bx - cx, by - cy, true)
        end
    end

    if not isballshown then
        balltimer2 = balltimer2 + dt
        if balltimer2 >= 4 then
            balltimer2 = 0
local tDx, tDy = findNearestChest(x2 + logo2W/2, y2 + logo2H/2)
if tDx then map1_setDirection(tDx, tDy, false) end
        end

        local dx = (x + logoW/2) - (x2 + logo2W/2)
        local dy = (y + logoH/2) - (y2 + logo2H/2)
        local dist = math.sqrt(dx*dx + dy*dy)
        local minDist = 16 

        if dist < minDist then
            speedX, speedX2 = speedX2, speedX
            speedY, speedY2 = speedY2, speedY
            local push = (minDist - dist) / 2
            local nx, ny = dx/dist, dy/dist
            x, y = x + nx*push, y + ny*push
            x2, y2 = x2 - nx*push, y2 - ny*push
            if bumpTimer <= 0 then bumpsnd:stop(); bumpsnd:play(); bumpTimer = 0.1 end
        end

        local oldX, oldY = x, y
        x = x + speedX * dt
        for _, p in ipairs(playerSensors) do
            if isBlackPixel(x + p.x, y + p.y) then x = oldX; speedX = -speedX; break end
        end
        y = y + speedY * dt
        for _, p in ipairs(playerSensors) do
            if isBlackPixel(x + p.x, y + p.y) then y = oldY; speedY = -speedY; break end
        end

        local oldX2, oldY2 = x2, y2
        x2 = x2 + speedX2 * dt
        for _, p in ipairs(playerSensors) do
            if isBlackPixel(x2 + p.x, y2 + p.y) then x2 = oldX2; speedX2 = -speedX2; break end
        end
        y2 = y2 + speedY2 * dt
        for _, p in ipairs(playerSensors) do
            if isBlackPixel(x2 + p.x, y2 + p.y) then y2 = oldY2; speedY2 = -speedY2; break end
        end
    end

    for i = #chests, 1, -1 do
        local c = chests[i]
        if x < c.x + chestW and x + logoW > c.x and y < c.y + chestH and y + logoH > c.y then
            table.remove(chests, i)
            chestcount_h1 = chestcount_h1 + 1
            chestsnd:stop(); chestsnd:play()
            
            local curMag = math.sqrt(speedX^2 + speedY^2)
            if curMag == 0 then curMag = savedMag1 end
            speedX, speedY = (speedX/curMag)*(curMag+speedGain), (speedY/curMag)*(curMag+speedGain)
            savedMag1 = curMag + speedGain

            if gameMode == "timetrial" then
                local rx, ry = findValidChestPosition()
                table.insert(chests, {x = rx, y = ry})
            end

        elseif x2 < c.x + chestW and x2 + logo2W > c.x and y2 < c.y + chestH and y2 + logo2H > c.y then
            table.remove(chests, i)
            chestcount_h2 = chestcount_h2 + 1
            chestsnd:stop(); chestsnd:play()

            local curMag = math.sqrt(speedX2^2 + speedY2^2)
            if curMag > 0 then
                speedX2, speedY2 = (speedX2/curMag)*(curMag+speedGain), (speedY2/curMag)*(curMag+speedGain)
            end

            if gameMode == "timetrial" then
                local rx, ry = findValidChestPosition()
                table.insert(chests, {x = rx, y = ry})
            end
        end
    end

    if gameMode == "classic" and #chests == 0 and not isFading then 
        allChestsEaten() 
    end
end

function map1_drawRoom()
    local viewW, viewH = TOP_W / zoom, TOP_H / zoom
    local camX = math.max(0, math.min(x - viewW/2, mapW - viewW))
    local camY = math.max(0, math.min(y - viewH/2, mapH - viewH))

    love.graphics.push()
    love.graphics.scale(zoom, zoom)
    love.graphics.translate(-camX, -camY)
    love.graphics.draw(obstacle, 0, 0)
    for _, c in ipairs(chests) do love.graphics.draw(chest, c.x, c.y) end
    love.graphics.draw(logo, x, y)
    love.graphics.draw(logo2, x2, y2)
    love.graphics.pop()
end

function map1_drawBottomRoom()
    if bottomBG then love.graphics.draw(bottomBG, 0, 0) end
    if isballshown then love.graphics.draw(dirCir, 120, 90) end

    love.graphics.setColor(0,0,0)
    
    if gameMode == "timetrial" then
        local mins, secs = math.floor(timer/60), math.floor(timer%60)
        local ms = math.floor((timer*1000)%1000)
        
        love.graphics.print(string.format("TIME LEFT: %02d:%02d:%03d", mins, secs, ms), 5, 5)
        love.graphics.print("ORANGE: " .. chestcount_h1, 10, 30)
        love.graphics.print("BLUE: " .. chestcount_h2, 10, 50)
    else
        local mins, secs = math.floor(timer/60), math.floor(timer%60)
        local ms = math.floor((timer*1000)%1000)
        love.graphics.print(string.format("TIME: %02d:%02d:%03d", mins, secs, ms), 5, 5)
    end
    
    love.graphics.setColor(1,1,1)
end

function map1_resetRoom()
    x, y = 60, 45
    x2, y2 = 377, 392
    speedX, speedY = 100, 100
    speedX2, speedY2 = 100, 100
    savedMag1 = 150
    zoom = 1.6
    balltimer, balltimer2 = 0, 0
    isballshown = false
    chestcount_h1, chestcount_h2 = 0, 0

    if gameMode == "classic" then timer = 0 end 
    spawnChests(9)
end

function map1_unload()
    obstacle = nil
    mapData = nil
    collectgarbage("collect")
end