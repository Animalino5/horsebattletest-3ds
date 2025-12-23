require("nest").init({console = "3ds"})
love.graphics.setDefaultFilter("nearest", "nearest")

TOP_W, TOP_H = 400, 240
BOT_W, BOT_H = 320, 240
whowon = ""
currentRoom = "titlescreen"
timer = 0
fadeAlpha = 0
fadeSpeed = 4
isFading = false
nextRoom = nil
highScores = {
    map1 = { time = 9999, chests = 0 },
    map2 = { time = 9999, chests = 0 }
}
gameMode = "classic"
        
        nextMapChoice = ""

function startFade(roomName)
    isFading = true
    nextRoom = roomName
    fadeAlpha = 0
end

function saveToSD()
    local data = string.format("%f|%d|%f|%d", 
        highScores.map1.time, highScores.map1.chests,
        highScores.map2.time, highScores.map2.chests)
    
    love.filesystem.write("highscores_v2.txt", data)
end

function loadFromSD()
    if love.filesystem.getInfo("highscores_v2.txt") then
        local content = love.filesystem.read("highscores_v2.txt")

        if content and content ~= "" then
            local scores = {}
            for val in string.gmatch(content, "([^|]+)") do
                table.insert(scores, tonumber(val))
            end

            if #scores >= 4 then
                highScores.map1.time = scores[1] or 9999
                highScores.map1.chests = scores[2] or 0
                highScores.map2.time = scores[3] or 9999
                highScores.map2.chests = scores[4] or 0
                return
            end
        end
    end

    highScores = {
        map1 = { time = 9999, chests = 0 },
        map2 = { time = 9999, chests = 0 }
    }
end

require("titlescreen")

function love.load()
    bottomBG = love.graphics.newImage("ASSETS/bg.png")
    dirCir   = love.graphics.newImage("ASSETS/directioncircle.png")
    
    loadFromSD()

    titlescreen_loadRoom()
end

function love.update(dt)
    
collectgarbage("setpause", 100) 

collectgarbage("setstepmul", 5000)

    if (currentRoom == "map1" or currentRoom == "map2") and not bgm:isPlaying() then
        
    end

    if currentRoom == "map1" and map1_updateRoom then map1_updateRoom(dt)
    elseif currentRoom == "map2" and map2.updateRoom then map2.updateRoom(dt)
    elseif currentRoom == "titlescreen" and titlescreen_updateRoom then titlescreen_updateRoom(dt)
    elseif currentRoom == "win" and win_updateRoom then win_updateRoom(dt) end

    if isFading then
        fadeAlpha = fadeAlpha + fadeSpeed * dt

    if fadeAlpha >= 1 then
        if currentRoom == "titlescreen" then
            titleScreen = nil; but1 = nil; but2 = nil
        elseif currentRoom == "win" then
            orangeWin = nil; blueWin = nil; winBG = nil
        elseif currentRoom == "map1" then
            map1_unload()
        elseif currentRoom == "map2" then
            map2.unload()
        end

        collectgarbage("collect")
        collectgarbage("collect")

        currentRoom = nextRoom
        
        if currentRoom == "titlescreen" then titlescreen_loadRoom()
        elseif currentRoom == "map1" then require("map1"); map1_loadRoom()
        elseif currentRoom == "map2" then require("map2"); map2.loadRoom()
      elseif currentRoom == "win" then require("win"); win_loadRoom()
        elseif currentRoom == "modeselect" then require("modeselect"); modeselect_loadRoom()
        end

        isFading = false
        fadeAlpha = 1
    end
end
end

function love.draw(screen)

    if screen == "bottom" then
      
        if currentRoom == "map1" then map1_drawBottomRoom()
      elseif currentRoom == "map2" then map2.drawBottomRoom()
        elseif currentRoom == "modeselect" then modeselect_drawBottomRoom()
        elseif currentRoom == "titlescreen" then titlescreen_drawBottomRoom()
        elseif currentRoom == "win" then win_drawBottomRoom() end

    else
        
        if currentRoom == "map1" then map1_drawRoom()
        elseif currentRoom == "map2" then map2.drawRoom()
        elseif currentRoom == "titlescreen" then titlescreen_drawRoom()
      elseif currentRoom == "win" then win_drawRoom()               
  end

        if isFading then
            --love.graphics.setColor(0, 0, 0, fadeAlpha)
            --love.graphics.rectangle("fill", 0, 0, TOP_W, TOP_H)
            --love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if currentRoom == "titlescreen" then
        titlescreen_touchpressed(x, y)
        elseif currentRoom == "modeselect" then
        modeselect_touchpressed(x, y)
    elseif currentRoom == "win" then
        win_touchpressed(x, y)
    end
end

function love.keypressed(key)
    if currentRoom == "map1" then
        if map1_keypressed then map1_keypressed(key) end
    elseif currentRoom == "map2" then
        if map2 and map2.keypressed then map2.keypressed(key) end
    end
end
function love.gamepadpressed(joystick, button)
    love.keypressed(button) 
end

function checkAndSaveScore(mapName, value)
  
  if not highScores[mapName] then return false end
  
    if gameMode == "classic" then
        if value < highScores[mapName].time then
            highScores[mapName].time = value
            saveToSD()
            return true
        end
    elseif gameMode == "timetrial" then
        if value > highScores[mapName].chests then
            highScores[mapName].chests = value
            saveToSD()
            return true
        end
    end
    return false
end