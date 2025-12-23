local btnClassic, btnTimeTrial
local btnW, btnH = 200, 100

function modeselect_loadRoom()
    btnClassic = love.graphics.newImage("ASSETS/classicbutton.png")
    btnTimeTrial = love.graphics.newImage("ASSETS/timetrialbutton.png")
end

function modeselect_drawBottomRoom()
    if bottomBG then
        love.graphics.draw(bottomBG, 0, 0)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(btnClassic, 60, 20)
    love.graphics.draw(btnTimeTrial, 60, 130)
end

function modeselect_touchpressed(tx, ty)

    if tx > 60 and tx < 260 and ty > 20 and ty < 120 then
                      bgm:setLooping(true)
        bgm:setVolume(0.3)
        bgm:play()
        gameMode = "classic"
        timer = 0 
        startFade(nextMapChoice)
    end

    if tx > 60 and tx < 260 and ty > 130 and ty < 230 then
                      bgm:setLooping(true)
        bgm:setVolume(0.3)
        bgm:play()
        gameMode = "timetrial"
        timer = 60 
        startFade(nextMapChoice)
    end
end