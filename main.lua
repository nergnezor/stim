local loveblobs = require "loveblobs"
local util = require "loveblobs.util"

local softbodies = {}
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

function clamp(v, a, b) return (v < a and a) or (v > b and b) or v end
function isCloser(x, y, a, b)
    return math.pow(x - a.x, 2) + math.pow(y - a.y, 2) < math.pow(x - b.x, 2) +
               math.pow(y - b.y, 2)
end
function closest(id, x, y)

    local closestI = 1
    for i, player in ipairs(players) do
        if not i == closestI and isCloser(x, y, players[i], players[closestI]) then
            closestI = i
        end
    end
    return closestI
end
function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width,
                                                                height,
                                                                image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end
debug = true
function love.load()
    print("testErik")
    if love.filesystem.getInfo("SDL_GameControllerDB/gamecontrollerdb.txt") then
        love.joystick.loadGamepadMappings(
            "SDL_GameControllerDB/gamecontrollerdb.txt")
    end
    love.graphics.setBackgroundColor(0.1, 0.4, 0.6)
    background = love.graphics.newImage("assets/oceanbg.png")
    player1.x = love.graphics.getWidth() / 2
    player1.y = love.graphics.getHeight() / 2

    love.physics.setMeter(16) -- the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 1 * 16, true) -- create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
    fishVertices = {
        0, 60, 50, 100, 100, 60, 140, 80, 130, 50, 140, 10, 100, 40, 50, 0
    }

    -- make a floor out of a softsurface
    local points = {
        0, love.graphics.getHeight(), 0, 0, 10, 0, 10,
        love.graphics.getHeight() - 100, love.graphics.getWidth() - 10,
        love.graphics.getHeight() - 100, love.graphics.getWidth() - 10, 10,
        love.graphics.getWidth(), 10, love.graphics.getWidth(),
        love.graphics.getHeight()
    }
    local b = loveblobs.softsurface(world, points, 64, "static")

    table.insert(softbodies, b)

    joysticks = {}
    nFound = 0
    for i, joystick in ipairs(love.joystick.getJoysticks()) do
        print(joystick:getName())
        if string.find(joystick:getName(), "Controller") then
            print("Added: " .. joystick:getName())
            nFound = nFound + 1
            joysticks[nFound] = joystick
            -- a softbody
            local b = loveblobs.softbody(world, 200 * nFound, 0, 40, 2, 4)
            -- b:setFrequency(60)
            -- b:setDamping(1000)
            -- b:setFriction(10000)
            table.insert(softbodies, b)
        end
    end
end

function love.update(dt)
    require("lurker").update()
    world:update(dt) -- this puts the world into motion

    for i, v in ipairs(softbodies) do
        world:update(dt) -- this puts the world into motion
        v:update(dt)

        local body = nil
        if tostring(v) == "softbody" then
            body = v.centerBody
            x, y = body:getPosition()
            dx = 5000 * joysticks[i - 1]:getAxis(1)
            dy = 5000 * joysticks[i - 1]:getAxis(2)
            body:applyForce(dx, dy)
        end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure) end

function love.joystickadded(joystick) end

local lastbutton = "none"
local lastStick = "none"

function love.joystickpressed(joystick, button)
    lastbutton = button
    lastStick = joystick:getName()
    p1joystick = joystick
    print("pressed")
end

function love.draw()
    -- love.graphics.circle('fill', players[1].x, players[1].y, 100, 64)
    for i, v in ipairs(softbodies) do
        -- love.graphics.setColor(50 * i, 100, 200 * i)
        if (tostring(v) == "softbody") then
            v:draw("line", false)
        else
            v:draw(false)
        end
    end
end
