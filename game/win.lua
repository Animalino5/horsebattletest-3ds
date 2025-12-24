playedJingle = false 

function win_loadRoom()
    orangeWin = love.graphics.newImage("assets/orangewin.png")
    blueWin = love.graphics.newImage("assets/bluewin.png")
    winBG = love.graphics.newImage("assets/winBG.png")
    tieWin = love.graphics.newImage("assets/tie.png")

    orangeJingle = love.audio.newSource("assets/orangewin.wav", "static")
    blueJingle = love.audio.newSource("assets/bluewin.wav", "static")
    tieJingle = love.audio.newSource("assets/tiewin.wav", "static")
end

function win_updateRoom(dt)
  
    if not playedJingle then
        love.audio.stop() 
        
        bgm:stop()
        
        if whowon == "or" then
            orangeJingle:play()
        elseif whowon == "bl" then
            blueJingle:play()
            elseif whowon == "tie" then
            tieJingle:play()
        end
        playedJingle = true
    end
end

function win_drawRoom()
    if whowon == "or" then
        love.graphics.draw(orangeWin, 0, 0)
    elseif whowon == "bl" then
        love.graphics.draw(blueWin, 0, 0)
        elseif whowon == "tie" then
        love.graphics.draw(tieWin, 0, 0)
    end
end

function win_drawBottomRoom()
    love.graphics.draw(winBG, 0, 0)
    bgm:stop()
    love.graphics.setColor(0, 0, 0) 
    
    if whowon == "or" then
        love.graphics.print("ORANGE COLLECTED THE MOST CHESTS!", 35, 100)
    elseif whowon == "bl" then
        love.graphics.print("BLUE COLLECTED THE MOST CHESTS!", 45, 100)
        elseif whowon == "tie" then
        love.graphics.print("IT IS A TIE!!!", 100, 100)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function win_touchpressed(tx, ty)
    whowon = ""        
    playedJingle = false 
    
    startFade("titlescreen") 
end