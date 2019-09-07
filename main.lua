platform = {}
player1 = {}
player2 = {}
players = {player1,player2}
scale = 0.2
function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end
function love.load()
	if love.filesystem.getInfo("SDL_GameControllerDB/gamecontrollerdb.txt") then
		love.joystick.loadGamepadMappings("SDL_GameControllerDB/gamecontrollerdb.txt")
	end
	-- love.window.maximize()
	platform.width = love.graphics.getWidth()
	platform.height = love.graphics.getHeight()
 
	platform.x = 0
	platform.y = platform.height / 2
 
	player1.x = love.graphics.getWidth() / 2
	player1.y = love.graphics.getHeight() / 2
 
	player1.speed = 400
 
	
	player1.ground = player1.y
	
	player1.y_velocity = 0
	
	player1.jump_height = -300
	player1.gravity = -500
	player1.scale = scale
	player2 = deepCopy(player1)
	player1.img = love.graphics.newImage('assets/liten.png')
	player2.img = love.graphics.newImage('assets/stor.png')
	print('ws ')

	p1joystick = nil
	animation = newAnimation(love.graphics.newImage("assets/bossfish.ss.png"), 314, 219, 1)

end
-- function love.joystickadded(joystick)
--     p1joystick = joystick
-- end
function love.update(dt)
	animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
    end
	-- table.foreach(players, print)
	if p1joystick ~= nil then
        -- getGamepadAxis returns a value between -1 and 1.
        -- It returns 0 when it is at rest
 
        player1.x = player1.x + p1joystick:getGamepadAxis("leftx")
        player1.x = player1.x + p1joystick:getGamepadAxis("lefty")
    end
	if love.keyboard.isDown('right') then
		if player1.x < (love.graphics.getWidth() - player1.img:getWidth()*scale) then
			player1.x = player1.x + (player1.speed * dt)
		end
	end 
	if love.keyboard.isDown('left') then
		if player1.x > 0 then 
			player1.x = player1.x - (player1.speed * dt)
		end
	end 
	if love.keyboard.isDown('up') then
		if player1.y > 0 then 
			player1.y = player1.y - (player1.speed * dt)
		end
	end 
	if love.keyboard.isDown('down') then
		if player1.y < (love.graphics.getHeight() - player1.img:getHeight()*scale) then 
			player1.y = player1.y + (player1.speed * dt)
		end
	end
	if love.keyboard.isDown('d') then
		if player2.x < (love.graphics.getWidth() - player2.img:getWidth()*scale) then
			player2.x = player2.x + (player2.speed * dt)
		end
	end 
	if love.keyboard.isDown('a') then
		if player2.x > 0 then 
			player2.x = player2.x - (player2.speed * dt)
		end
	end 
	if love.keyboard.isDown('w') then
		if player2.y > 0 then 
			player2.y = player2.y - (player2.speed * dt)
		end
	end 
	if love.keyboard.isDown('s') then
		if player2.y < (love.graphics.getHeight() - player2.img:getHeight()*scale) then 
			player2.y = player2.y + (player2.speed * dt)
		end
	end
 
	-- if love.keyboard.isDown('space') then
	-- 	if player1.y_velocity == 0 then
	-- 		player1.y_velocity = player1.jump_height
	-- 	end
	-- end
 
	-- if player1.y_velocity ~= 0 then
	-- 	player1.y = player1.y + player1.y_velocity * dt
	-- 	player1.y_velocity = player1.y_velocity - player1.gravity * dt
	-- end
 
	-- if player1.y > player1.ground then
	-- 	player1.y_velocity = 0
    -- 	player1.y = player1.ground
	-- end
end
function love.joystickadded(joystick)
	-- if love.joystick.getJoystickCount() == 0 then
	-- 	-- Controller[1] = joystick
	-- elseif love.joystick.getJoystickCount() == 1 then
	-- 	Controller[2] = joystick
	-- elseif love.joystick.getJoystickCount() == 2 then
	-- 	Controller[3] = joystick
	-- elseif love.joystick.getJoystickCount() == 3 then
	-- 	Controller[4] = joystick
	-- end
	
end    

local lastbutton = "none"
local lastStick = "none"
function love.joystickpressed(joystick,button)
	-- player:jumping()
	-- love.graphics.print(joystick.." "..buttom, 50, 100 )

	lastbutton = button
	lastStick = joystick:getName()
	p1joystick = joystick
end


function love.gamepadpressed(joystick, button)
	-- lastbutton = button
	-- lastStick = joystick:getName()
	-- p1joystick = joystick
 end
--  end
function love.draw()
	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum])
	love.graphics.print(lastStick.." , Last gamepad button pressed: "..lastbutton, 0, 0)

	-- love.graphics.print("JOYSTICK COUNT:"..love.joystick.getJoystickCount(), 250, 180 )
	local joysticks = love.joystick.getJoysticks()
	nFound = 0
    for i, joystick in ipairs(joysticks) do
		-- joystick:open()
		if not joystick:isGamepad() and string.find(joystick:getName(),"Controller" ) then
			nFound = nFound + 1
			-- love.graphics.print(joystick:getName().."\tgetAxisCount: "..joystick:getAxisCount().."\tIS A GAMEPAD?: "..tostring(joystick:isGamepad()).." \tgetButtonCount?: "..tostring(joystick:getButtonCount().." \ttriggerright: "..joystick:getGamepadAxis('triggerright')), 0, 2*nFound * 20)
			inputtype, inputindex, hatdirection = joystick:getAxes()
			for j=1,joystick:getAxisCount() do
				love.graphics.print(string.format("%02.2f",joystick:getAxis(j)), j* 50, (1+2*nFound) * 20)
				-- love.graphics.print(string:format("%02.2f",joystick:getAxis(j)), j* 50, (1+2*nFound) * 20)
			end
			-- inputtype, inputindex, hatdirection = joystick:getGamepadMapping( "lefty" )
			-- love.graphics.print("d:"..tostring(inputtype).." "..tostring(inputindex).." "..tostring(hatdirection), 0, 200 + nFound * 20)

				-- love.graphics.print(joystick:getHat(1)..joystick:getGamepadAxis("lefty"), 100, (1+2*nFound) * 20)
			-- end
		end
	end
	love.graphics.setColor(0.9, 0.5, 1)
	-- love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
 
	love.graphics.draw(player1.img, player1.x, player1.y, 0, scale, scale, 0, 32)
	love.graphics.draw(player2.img, player2.x, player2.y, 0, scale, scale, 0, 32)
	-- local joysticks = love.joystick.getJoysticks()
    -- local joystickcount = love.joystick.getJoystickCount( )
    -- for i, joystick in ipairs(joysticks) do
    --     love.graphics.print("JOYSTICK NAME:"..joystick:getName(), 250, i * 160)
    -- end
	-- love.graphics.print("JOYSTICK COUNT:"..joystickcount, 250, 180 )
	-- local joysticks = love.joystick.getJoysticks()
	-- id = 1
	-- joysticks[id]:setVibration(0,0)
    -- local joystickcount = love.joystick.getJoystickCount( )
    -- local axes = joysticks[id]:getAxisCount()
    -- local buttoncount = joysticks[id]:getButtonCount()
    -- local controlGUID = joysticks[id]:getGUID()
    -- local controlID = joysticks[id]:getID()
    -- local vibSupport = joysticks[id]:isVibrationSupported()
    -- local isGamepad = joysticks[id]:isGamepad()
    -- local isConnected = joysticks[id]:isConnected()
    -- local countMyHats = joysticks[id]:getHatCount()
    -- local hatPosWhere = joysticks[id]:getHat(1)
    -- local howsMyVibBroL, howsMyVibBroR = joysticks[id]:getVibration()
    -- local axisDir1, axisDir2, axisDir3, axisDir4 = joysticks[id]:getAxes( )
    -- local button1down = joysticks[id]:isDown(1)
    -- local button2down = joysticks[id]:isDown(2)
    -- local button3down = joysticks[id]:isDown(3)
    -- local button4down = joysticks[id]:isDown(4)
    -- local button5down = joysticks[id]:isDown(5)
    -- local button6down = joysticks[id]:isDown(6)
    -- local button7down = joysticks[id]:isDown(7)
    -- local button8down = joysticks[id]:isDown(8)
    -- local button9down = joysticks[id]:isDown(9)
    -- local button10down = joysticks[id]:isDown(10)
    -- local button11down = joysticks[id]:isDown(11)
    -- local button12down = joysticks[id]:isDown(12)

    -- love.graphics.setColor(0,255,0)
    -- for i, joystick in ipairs(joysticks) do
    --     love.graphics.print("JOYSTICK NAME:"..joystick:getName(), 0, i * 160)
    -- end
    -- love.graphics.print("JOYSTICK GUID:"..controlGUID, 0, 200 )
    -- love.graphics.print("JOYSTICK ID:"..controlID, 0, 240 )
    -- love.graphics.print("JOYSTICK COUNT:"..joystickcount, 0, 280 )
    -- love.graphics.print("JOYSTICK AXIS COUNT:"..axes, 0, 320 )
    -- love.graphics.print("JOYSTICK BUTTON COUNT:"..buttoncount, 0, 360 )
    -- love.graphics.print("VIBRATION SUPPORTED?:"..tostring(vibSupport), 0, 400 )
    -- love.graphics.print("IS A GAMEPAD?:"..tostring(isGamepad), 0, 440)
    -- love.graphics.print("IS CONNECTED?:"..tostring(isConnected), 0, 480)
    -- love.graphics.print("JOYSTICK HATS COUNT:"..countMyHats, 0, 520)
    -- love.graphics.print("VIBRATION LEVEL LEFT:"..howsMyVibBroL.." VIBRATION LEVEL RIGHT:"..howsMyVibBroR, 0, 560)
    -- love.graphics.print("AXIS 1 = "..axisDir1, 400,240)
    -- love.graphics.print("AXIS 2 = "..axisDir2, 400,280)
    -- love.graphics.print("AXIS 3 = "..axisDir3, 400,320)
    -- love.graphics.print("AXIS 4 = "..axisDir4, 400,360)
    -- love.graphics.print("B01 DOWN?:"..tostring(button1down), 0, 0)
    -- love.graphics.print("B02 DOWN?:"..tostring(button2down), 200, 0)
    -- love.graphics.print("B03 DOWN?:"..tostring(button3down), 770, 0)
    -- love.graphics.print("B04 DOWN?:"..tostring(button4down), 400, 0)
    -- love.graphics.print("B05 DOWN?:"..tostring(button5down), 0, 40)
    -- love.graphics.print("B06 DOWN?:"..tostring(button6down), 200, 40)
    -- love.graphics.print("B07 DOWN?:"..tostring(button7down), 770, 40)
    -- love.graphics.print("B08 DOWN?:"..tostring(button8down), 400, 40)
    -- love.graphics.print("B09 DOWN?:"..tostring(button9down), 0, 80)
    -- love.graphics.print("B010 DOWN?:"..tostring(button10down), 200, 80)
    -- love.graphics.print("B011 DOWN?:"..tostring(button11down), 770, 80)
    -- love.graphics.print("B012 DOWN?:"..tostring(button12down), 400, 80)
    -- love.graphics.print("HAT POSITION?:"..hatPosWhere, 200, 240)
end