local loveblobs = require "loveblobs"
local util = require "loveblobs.util"
-- Converts HSL to RGB. (input and output range: 0 - 255)
function HSL(h, s, l, a)
    if s <= 0 then return l, l, l, a end
    h, s, l = h / 256 * 6, s / 255, l / 255
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = (1 - math.abs(h % 2 - 1)) * c
    local m, r, g, b = (l - .5 * c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return (r + m) * 1, (g + m) * 1, (b + m) * 1, a
end

local softbodies = {}

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

function love.load()
    print("testErik")
    if love.filesystem.getInfo("SDL_GameControllerDB/gamecontrollerdb.txt") then
        love.joystick.loadGamepadMappings(
            "SDL_GameControllerDB/gamecontrollerdb.txt")
    end
    love.graphics.setBackgroundColor(0.1, 0.4, 0.6)
    background = love.graphics.newImage("assets/oceanbg.png")

    love.physics.setMeter(16) -- the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 1 * 16, true) -- create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
    -- -- make a floor out of a softsurface
    -- local points = {
    --     0, love.graphics.getHeight(), 0, 0, 10, 0, 10,
    --     love.graphics.getHeight() - 100, love.graphics.getWidth() - 10,
    --     love.graphics.getHeight() - 100, love.graphics.getWidth() - 10, 10,
    --     love.graphics.getWidth(), 10, love.graphics.getWidth(),
    --     love.graphics.getHeight()
    --     -- 0, love.graphics.getHeight(), 0, 0, 10, 0, 10,
    --     -- love.graphics.getHeight() - 10, love.graphics.getWidth() - 10,
    --     -- love.graphics.getHeight() - 10, love.graphics.getWidth() - 10, 10, 10,
    --     -- 10, 0, 0, love.graphics.getWidth(), 0, love.graphics.getWidth(), 10,
    --     -- love.graphics.getWidth(), love.graphics.getHeight()
    -- }
    -- local b = loveblobs.softsurface(world, points, 64, "static")
    -- table.insert(softbodies, b)
    local points = {-10000, 1000, 10000, 1000, 10000, 10000, -10000, 10000}
    local b = loveblobs.softsurface(world, points, 64, "static")
    table.insert(softbodies, b)

    for i = 1, math.random(200) do
        x = math.random(love.graphics.getWidth() * 20) -
                love.graphics.getWidth() * 10 / 2
        y = math.random(love.graphics.getHeight() * 10) -
                love.graphics.getWidth() * 10 / 2
        -- make a floor out of a softsurface
        local points = {
            x + math.random(30, 100), y + math.random(30, 100),
            x + math.random(110, 400), y + math.random(30, 100),
            x + math.random(110, 400), y + math.random(110, 400),
            x + math.random(30, 100), y + math.random(110, 400)
        }
        local b = loveblobs.softsurface(world, points, 64, "static")
        table.insert(softbodies, b)
    end

    joysticks = {}
    nFound = 0
    for i, joystick in ipairs(love.joystick.getJoysticks()) do
        print(joystick:getName())
        if string.find(joystick:getName(), "Controller") then
            print("Added: " .. joystick:getName())
            nFound = nFound + 1
            joysticks[nFound] = joystick
            -- a softbody
            local b = loveblobs.softbody(world, 200 * nFound, 100, 40, 2, 4)
            b:setFrequency(2)
            -- b:setDamping(1000)
            -- b:setFriction(10000)
            table.insert(softbodies, b)
        end
    end
    for i = 1, 50 do
        x = math.random(2000) - 1000
        y = math.random(2000) - 1000
        r = 10 + math.random(10)
        local b = loveblobs.softbody(world, x, y, r, 2, 4)
        table.insert(softbodies, b)
    end
end
scale = 1

function love.update(dt)
    require("lurker").update()
    for i = 1, 4 do world:update(dt) end
    diagonal = util.dist(love.graphics.getWidth(), love.graphics.getHeight(), 0,
                         0)
    mindist = diagonal * 0.4
    maxdist = mindist
    mindistX = love.graphics.getWidth() * 0.6
    mindistY = love.graphics.getHeight() * 0.6
    maxdistX = mindistX
    maxdistY = mindistY
    -- scale = 1
    cx = 0
    cy = 0
    nbodies = 0
    panRight = nil
    count = 0
    for i, v in ipairs(softbodies) do
        v:update(dt)
        if tostring(v) == "softbody" then
            count = count + 1
            if joysticks[count] then
                body = v.centerBody
                x, y = body:getPosition()
                -- local a1 = 3
                -- local a2 = 6
                -- if i % 2 == 0 then
                --     a1 = 1
                --     a2 = 2
                -- end
                dx = 10000 * joysticks[count]:getAxis(1)
                dy = 10000 * joysticks[count]:getAxis(2)
                body:applyForce(dx, dy)
                for j, v2 in ipairs(softbodies) do
                    if j > i then
                        x2, y2 = softbodies[j].centerBody:getPosition()
                        dist = util.dist(x, y, x2, y2)
                        if dist > maxdist then
                            maxdist = dist
                        end
                        if math.abs(x - x2) > maxdistX then
                            maxdistX = math.abs(x - x2)
                        end
                        if math.abs(y - y2) > maxdistY then
                            maxdistY = math.abs(y - y2)
                        end
                    end
                end

                cx = cx + x * scale
                cy = cy + y * scale
                nbodies = nbodies + 1
            end
        end
    end
    cx = cx / nbodies
    cy = cy / nbodies
    -- scale 1: maxdist < 90% diagonal
    -- scale 0.5: maxdist < 90% diagonal
    -- if maxdist > mindist and scale > 0.5 then
    --     -- print(maxdist)
    --     scale = scale - 0.001
    -- end
    -- if maxdist/scale > 0.9* diagonal and scale > 0.001  then scale = scale - 0.001 end
    -- if (maxdist > diagonal) then scale = 1 - maxdist / diagonal end
end

function love.joystickpressed(joystick, button)
    print("pressed")
    for i, v in ipairs(softbodies) do
        if tostring(v) == "softbody" then
            v.centerBody:setPosition(love.graphics.getWidth() / 2,
                                     love.graphics.getHeight() / 2)
        end
    end
    screenX, screenY = love.graphics.transformPoint(x, y)
    print(screenX, screenY, x, y)
end

function love.draw()
    -- love.graphics.draw(background, 0, 0)
    love.graphics.push()
    dx = -cx + love.graphics.getWidth() / 2
    dy = -cy + love.graphics.getHeight() / 2
    love.graphics.translate(dx / 1, dy / 1)
    scale = 1 / math.max((maxdistX / mindistX), (maxdistY / mindistY))
    scale = math.min(1, scale)
    if scale < 1 and scale > 0.1 then love.graphics.scale(scale, scale) end
    for i, v in ipairs(softbodies) do
        -- love.graphics.setColor(0.2 * i, 0.2 * i, 0.2 * i)

        love.graphics.setColor(HSL(100 * i % 255, 255 - 30, 200 - 30, 0.3))
        if (tostring(v) == "softbody") then
            v:draw("fill", false)
            love.graphics.setColor(HSL(100 * i % 255, 255, 200, 0.3))
            v:draw("line", false)
        else
            v:draw(false)
        end
    end
    love.graphics.pop()
end
