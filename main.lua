

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
	love.graphics.setBackgroundColor(0.1,0.4,0.6)
	background = love.graphics.newImage("assets/oceanbg.png")
	player1.x = love.graphics.getWidth() / 2
	player1.y = love.graphics.getHeight() / 2
 
	player1.scale = scale
	player1.rotation = 0
	player2 = deepCopy(player1)
	player1.img = love.graphics.newImage('assets/liten.png')
	player2.img = love.graphics.newImage('assets/stor.png')
	players = {player1,player2}

	animation = newAnimation(love.graphics.newImage("assets/bossfish.ss.png"), 314, 219,1)

	joysticks = {}
	nFound = 0
    for i, joystick in ipairs(love.joystick.getJoysticks()) do
		if not joystick:isGamepad() and string.find(joystick:getName(),"Controller" ) then
			nFound = nFound + 1
			joysticks[nFound] = joystick
		end
	end

	bgImage = love.graphics.newImage('assets/pink-gradient.png')
	bgImage:setWrap('repeat', 'clamp')
	WIDTH = 100
	bgQuad = love.graphics.newQuad(
		0, 0,
		bgImage:getWidth(), 100,
		bgImage:getWidth(), bgImage:getHeight()
	)

	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  	world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	objects = {} -- table to hold all our physical objects
	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape(650, 50) --make a rectangle with a width of 650 and a height of 50
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body
 
	--let's create a ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	fishVertices = {0,60,50,100,100,60,140,80,130,50,140,10,100,40,50,0}
	objects.ball.shape = love.physics.newPolygonShape( fishVertices )
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
	objects.ball.fixture:setRestitution(0.9) --let the ball bounce
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
	objects.ball.fixture:setRestitution(0.9) --let the ball bounce
end
counter = 0.01
step = 0.02
function love.update(dt)
	world:update(dt) --this puts the world into motion

	animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
		animation.currentTime = animation.currentTime - animation.duration
	end
	for i=1,#fishVertices/2 do
		x = 2 * i
		y = 2 * i + 1
		local amount = math.sin( counter )
		if i == 4 or i == 6 then
			fishVertices[(2 * i) - 1] = fishVertices[(2 * i) - 1] + amount*10*step
		end
		if (i == 3 or i == 7) then
			fishVertices[(2 * i) - 1] = fishVertices[(2 * i) - 1] + amount*2*step
		end
		if i == 5 then
			fishVertices[(2 * i) - 1] = fishVertices[(2 * i) - 1] + amount*5*step
		end
	end
	a = math.sin( counter )
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
	counter = counter + step
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
direction = 1
aprev = 0
light = 0
rgb = {0.5,0,0}
triangleLight = {0.1,0.2,0.4,0.3,0.1,0.3}
triangleZ = {0.2,-0.5,0.6,-0.9,0.9,-0.8}
function love.draw()
	love.graphics.print(string.format("%02.1f\t",a)..direction.."\t, light: "..string.format("%02.1f",light), 300, 200)

	local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum])
	-- love.graphics.setColor(0.9, 0.5, 1)
	for i, player in ipairs(players) do
		love.graphics.draw(player.img, player.x, player.y, player.rotation, scale, scale, player.img:getWidth()/2, player.img:getHeight()/2)
	end

	-- love.graphics.draw(bgImage, bgQuad, 200, 100)

	triangles = love.math.triangulate( fishVertices)
	love.graphics.translate(300, 10)
	if a > 0 and aprev <= 0 then
		direction = -direction
	end
	if a < 0 and aprev >= 0 then
		-- light = 0.5
	end
	aprev = a
	light = light + 0.1*direction*step
	for i, name in ipairs(triangles) do
		color = {}
		for j,v in ipairs(rgb) do
			color[j] = rgb[j] + triangleLight[i]
			-- if i > 2 then
				color[j] = color[j] + light * triangleZ[i]
			-- end
		end
		love.graphics.setColor(color) -- set the drawing color to green for the ground
		love.graphics.polygon("fill", name) -- draw a "filled in" polygon using the ground's coordinates
		love.graphics.setColor(1,1,1) -- set the drawing color to green for the ground
		love.graphics.polygon("line", name) -- draw a "filled in" polygon using the ground's coordinates
	end
	love.graphics.polygon("line", objects.ball.body:getWorldPoints(objects.ball.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
end