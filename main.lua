platform = {}
player1 = {}
player2 = {}
players = {player1,player2}

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

function love.load()
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
	
	player2 = deepCopy(player1)
	player1.img = love.graphics.newImage('assets/liten.png')
	player2.img = love.graphics.newImage('assets/stor.png')
	print('ws ')

end
 
function love.update(dt)
	-- table.foreach(players, print)
	if love.keyboard.isDown('right') then
		if player1.x < (love.graphics.getWidth() - player1.img:getWidth()) then
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
		if player1.y < (love.graphics.getHeight() - player1.img:getHeight()) then 
			player1.y = player1.y + (player1.speed * dt)
		end
	end
	if love.keyboard.isDown('d') then
		if player2.x < (love.graphics.getWidth() - player2.img:getWidth()) then
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
		if player2.y < (love.graphics.getHeight() - player2.img:getHeight()) then 
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
 
function love.draw()
	love.graphics.setColor(0.9, 0.5, 1)
	-- love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)
 
	love.graphics.draw(player1.img, player1.x, player1.y, 0, 1, 1, 0, 32)
	love.graphics.draw(player2.img, player2.x, player2.y, 0, 1, 1, 0, 32)
end