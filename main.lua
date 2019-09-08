platform = {}
player1 = {}
player2 = {}
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

-- Converts HSL to RGB. (input and output range: 0 - 255)
function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m)*255,(g+m)*255,(b+m)*255,a
end
function clamp(v,a,b)
    return (v < a and a) or (v > b and b) or v
end
function isCloser(x,y,a,b)
	return math.pow(x-a.x,2) + math.pow(y-a.y,2) < math.pow(x-b.x,2) + math.pow(y-b.y,2)
end
function closest(id,x,y)
 
	local closestI = 1
	for i, player in ipairs(players) do
		if not i == closestI and isCloser(x,y,players[i], players[closestI]) then
			closestI = i
		end
	end
	return closestI
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
	love.graphics.setBackgroundColor(HSL(150,100,200))
	background = love.graphics.newImage("assets/oceanbg.png")
	player1.x = love.graphics.getWidth() / 2
	player1.y = love.graphics.getHeight() / 2
 
	player1.scale = scale
	player1.rotation = 0
	player2 = deepCopy(player1)
	player1.img = love.graphics.newImage('assets/liten.png')
	player2.img = love.graphics.newImage('assets/stor.png')
	players = {player1,player2}

	print('ws ')
	
	animation = newAnimation(love.graphics.newImage("assets/bossfish.ss.png"), 314, 219, 2)
	joysticks = {}
	nFound = 0
    for i, joystick in ipairs(love.joystick.getJoysticks()) do
		if not joystick:isGamepad() and string.find(joystick:getName(),"Controller" ) then
			nFound = nFound + 1
			joysticks[nFound] = joystick
		end
	end
	
end
function love.update(dt)
	animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
    end
	local touches = love.touch.getTouches()
	for i, id in ipairs(touches) do
		local x, y = love.touch.getPosition(id)
		closestI = closest(id,x,y)
		player = players[closestI]
		player.x = (7 * player.x + x) / 8
		player.y = (7 * player.y + y) / 8
	end
	for i, player in ipairs(players) do
		if joysticks[i] == nil then 
			break 
		end
		player.x = player.x + 1 * joysticks[i]:getAxis(1)
		player.y = player.y + 1 * joysticks[i]:getAxis(2)
		player.rotation = player.rotation + 0.01 * joysticks[i]:getAxis(3)
		player.x = clamp(player.x, 0, love.graphics.getWidth())
		player.y = clamp(player.y, 0, love.graphics.getHeight())
	end
end
function love.touchpressed( id, x, y, dx, dy, pressure )


end
function love.joystickadded(joystick)
end    

local lastbutton = "none"
local lastStick = "none"
function love.joystickpressed(joystick,button)
	lastbutton = button
	lastStick = joystick:getName()
	p1joystick = joystick
end

function love.draw()
	love.graphics.draw(background)
	-- local spritenum = math.random(#animation.quads)

	local spriteNum = math.floor(animation.currentTime / animation.duration * math.random(#animation.quads)) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum])
	-- love.graphics.setColor(0.9, 0.5, 1)
	for i, player in ipairs(players) do
		love.graphics.draw(player.img, player.x, player.y, player.rotation, scale, scale, player.img:getWidth()/2, player.img:getHeight()/2)
	end
end