
function getRecordString(map, mode)
    if not highScores or not highScores[map] then return "No Record" end
    
    if mode == "classic" then
        local score = highScores[map].time
        if not score or score >= 9999 then
            return "No Record"
        else
            return string.format("%.2fs", score)
        end
    else 
        local score = highScores[map].chests
        if not score or score <= 0 then
            return "No Record"
        else
            return tostring(score) .. " Chests"
        end
    end
end

function titlescreen_loadRoom()
    titleScreen = love.graphics.newImage("ASSETS/titlescreen.png")
    but1        = love.graphics.newImage("ASSETS/map1button.png")
    but2        = love.graphics.newImage("ASSETS/map2button.png")

    if not bgm then
        bgm = love.audio.newSource("ASSETS/music.ogg", "stream")
    end

    button = {}
    button.x      = 140
    button.y      = 20
    button.y2     = 130
    button.w1     = but1:getWidth()
    button.h1     = but1:getHeight()
    button.w2     = but2:getWidth()
    button.h2     = but2:getHeight()

    if not highScores then
        highScores = {
            map1 = { time = 9999, chests = 0 },
            map2 = { time = 9999, chests = 0 }
        }
    end
    
    playedJingle = false
end

function titlescreen_updateRoom(dt)
    local joysticks = love.joystick.getJoysticks()
    local pad = joysticks[1]

    if pad then
        if pad:isGamepadDown("a") then
            bgm:setLooping(true)
            bgm:setVolume(0.3)
            bgm:play()
            nextMapChoice = "map1"
            startFade("modeselect")
        elseif pad:isGamepadDown("b") then
            bgm:setLooping(true)
            bgm:setVolume(0.3)
            bgm:play()
            nextMapChoice = "map2"
            startFade("modeselect")
        end
    end
end

function titlescreen_drawRoom()
    if titleScreen then
        love.graphics.draw(titleScreen, 0, 0)
    end
end

function titlescreen_drawBottomRoom()
        love.graphics.draw(bottomBG, 0, 0) 
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(but1, button.x, button.y)
    love.graphics.draw(but2, button.x, button.y2)
    
    love.graphics.setColor(0, 0, 0)
    
    love.graphics.print("MAP 1:", 20, 30)
    love.graphics.print("Classic: " .. getRecordString("map1", "classic"), 10, 50)
    love.graphics.print("Trial: " .. getRecordString("map1", "timetrial"), 10, 70)
    
    love.graphics.print("MAP 2:", 20, 120)
    love.graphics.print("Classic: " .. getRecordString("map2", "classic"), 10, 140)
    love.graphics.print("Trial: " .. getRecordString("map2", "timetrial"), 10, 160)
    
    love.graphics.setColor(1, 1, 1)
end

function titlescreen_touchpressed(tx, ty)
    if tx >= button.x and tx <= (button.x + button.w1) and
       ty >= button.y and ty <= (button.y + button.h1) then
        playedJingle = false 
        nextMapChoice = "map1"   
        startFade("modeselect")
    end
    
    if tx >= button.x and tx <= (button.x + button.w2) and
       ty >= button.y2 and ty <= (button.y2 + button.h2) then
        playedJingle = false 
        nextMapChoice = "map2"
        startFade("modeselect")
    end
end