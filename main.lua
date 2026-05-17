local ansi = require("libs.ansi")
local util = require("libs.utility")
local mathLib = require("libs.math")

local xPos, yPos = 0, 0
local rot = 0.1
local rotVelocity = 30
local velocity = 3

local fadeTheme = false
local volume = 0

local amplitude = 1
local sine = 0
local currentCat
local actualTheme

local width, height = love.graphics.getDimensions()

local centerX = width / 2
local centerY = height / 2

local lerp = mathLib.lerp
local clamp = mathLib.clamp

local coroutines = {}

math.randomseed(os.time())

local meow = love.audio.newSource("assets/sounds/sfx/meow4.wav", "static")
local step = love.audio.newSource("assets/sounds/sfx/step1.mp3", "static")

local sounds = love.filesystem.getDirectoryItems("assets/sounds/soundtrack/themes")
local chosenTheme = sounds[math.random(1, #sounds)]

local sleepSound = love.audio.newSource("assets/sounds/soundtrack/lullaby.wav", "stream")

-- por ora lidarei com flags pra lidar com dt e lerp e variaveis globais
actualTheme = love.audio.newSource("assets/sounds/soundtrack/themes/"..chosenTheme, "stream")

--step:setLooping(true)
actualTheme:setLooping(true)
sleepSound:setLooping(true)

sleepSound:setVolume(0.5)
actualTheme:setVolume(0)

sleepSound:play()
--step:setPitch(1.2)
--step:play()

-- fazer sistema de energia ao acordar o gato

local state = {
	["idle"] = "idle",
	["walk"] = "walk",
	["sleep"] = "sleep"
}

local cat = {
	image = {
		idle = love.graphics.newImage("assets/images/cat4.png"),
		sleep = love.graphics.newImage("assets/images/cat4sleep.png"),
	},
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0.27,
		y = 0.27,
	},

	state = state.sleep
}

-- task.delay do roblox, mas em coroutines de forma manual
local function delay(delay, fn)
    local co = coroutine.create(function()
        local timer = 0
        while timer < delay do
            timer = timer + coroutine.yield()
        end
        fn()
    end)
    coroutine.resume(co) -- inicia
    return co
end

local function update(image)
	currentCat = image
	imgWidth = image:getWidth()
	imgHeight = image:getHeight()
end


local function scaleSize(size)
	cat.size.x = size
	cat.size.y = size
end

local function catMovement(dt)
	if cat.state == state.sleep then return end

	-- tentar fazer rotacionar um pouco ao andar dando sensação de movimento

	local dx, dy = 0, 0

    if love.keyboard.isDown("up") then dy = dy - 1 end
    if love.keyboard.isDown("down") then dy = dy + 1 end
    if love.keyboard.isDown("right") then dx = dx + 1 end
    if love.keyboard.isDown("left") then dx = dx - 1 end

    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end
    if love.keyboard.isDown("a") then dx = dx - 1 end

    --print(cat.state)

    if dx ~= 0 or dy ~= 0 then
		cat.state = state.walk
    else
		cat.state = state.idle
    end

    if dx ~= 0 then
		cat.size.x = math.abs(cat.size.x) * dx
    end

    -- normaliza se tiver movimento em mais de uma direção
    -- usa raiz quadrada pra normalizar e impedir a soma dos vetores na diagonal
    local length = math.sqrt(dx * dx + dy * dy) -- teorema de pitagoras
    if length > 0 then
		dx = dx / length
		dy = dy / length
    end

    xPos = xPos + dx * 100 * dt
    yPos = yPos + dy * 100 * dt

    -- utilizar logica clamp e width/height da tela para limitar a tela

    -- centerX + xPos * velocity é a posição final do gato na tela
    -- print(clamp(centerX + xPos * velocity, -40, width))

    local halfW = (imgWidth * cat.size.x) / 2
	local halfH = (imgHeight * cat.size.y) / 2

    -- centerX e centerY ja é width/2 e height/2 da janela
    -- halfW e halfH permitem o gato não ficar metade fora da janela
    xPos = clamp(xPos, (-centerX - halfW) / velocity, (centerX - halfW) / velocity)
    yPos = clamp(yPos, (-centerY + halfH) / velocity, (centerY - halfH) / velocity)

    cat.position.x = xPos * velocity
    cat.position.y = yPos * velocity

end

local function onCat(mouseX, mouseY)
	local catDrawX = centerX + xPos * velocity
	local catDrawY = centerY + yPos * velocity

	local halfW = (imgWidth * cat.size.x) / 2
	local halfH = (imgHeight * cat.size.y) / 2

	if mouseX >= catDrawX - halfW and mouseX <= catDrawX + halfW and mouseY >= catDrawY - halfH and mouseY <= catDrawY + halfH then
		return true
	else
		return false
	end
end


local function onHover(mouseX, mouseY)
	local hover = onCat(mouseX, mouseY)
	if cat.state ~= state.sleep then return end

	-- reformular depois pra funçao de detecção geral
	if hover then
		scaleSize(lerp(cat.size.x, 0.3, 0.03))
	else
		scaleSize(lerp(cat.size.x, 0.27, 0.05))
	end
end

local function wakeUp()

	-- sistema de lampada/switch depois possivelmente?

	sleepSound:stop()

	math.randomseed(os.time())
	local pitch = math.random(7, 14) / 10

	meow:setPitch(pitch)
	meow:setVolume(0.5)
	meow:play()

	update(cat.image.idle)
	scaleSize(0.5)

	cat.state = state.idle

	rot = 0

	local co = delay(1, function()
		--print("printado após 1 segundo!")
		fadeTheme = true
		actualTheme:play()
	end)

	-- adiciona de forma manual á tabela que atualiza em love.update
	table.insert(coroutines, co)

end

-- // FUNÇÔES LOVE // --

function love.load() -- roda uma vez apenas

	bed = love.graphics.newImage("assets/images/bed.png")

	love.graphics.setNewFont(25) -- tamanho da fonte
	love.graphics.setBackgroundColor(46/255, 46/255, 51/255, 1)

	cat.state = state.sleep

	update(cat.image.sleep)
end

function love.update(dt) -- atualiza constantemente em delta time
	local mouseX, mouseY = love.mouse.getPosition()

	onHover(mouseX, mouseY)
	catMovement(dt)

	if fadeTheme then
		volume = lerp(volume, 0.35, 0.01)
		actualTheme:setVolume(volume)
	end

	-- -1 é um decrementador, itera diminuindo de trás pra frente
	for i = #coroutines, 1, -1 do
		local co = coroutines[i]
		local ok = coroutine.resume(co, dt)
		if not ok or coroutine.status(co) == "dead" then
			table.remove(coroutines, i)
		end
	end

	sine = sine + 1

	-- fazer lerp no valor de transição
	-- tentar arrumar depois e permitir animação idle junto de movimentação suave com seno
	if cat.state == state.idle then
		--rotVelocity = lerp(rotVelocity, 40, 0.02)
		amplitude = lerp(amplitude, 0, 0.05)
		--rot = lerp(rot, 0.05, 0.01)
		if amplitude < 0.01 then
			rotVelocity = 40
		end
		rot = 0.05
	elseif cat.state == state.walk then
		rotVelocity = 10
		--rotVelocity = lerp(rotVelocity, 10, 0.02)
		amplitude = lerp(amplitude, 1, 0.05)
		--rot = lerp(rot, 0.1, 0.01)
		rot = 0.1
	end

	--print(math.sin(sine/30))
end

function love.draw() -- renderiza frame por frame imagens e afins

	-- sx = scale x, sy = scale y
	-- r = rotação em radianos
	-- ox = ponto de origem offset, normalmente é 0,0 de anchor point
	-- oy = ponto de origem offset, mesmo caso acima^ mas para Y
	--love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)

	-- love.draw tem ordem de de desenho
	love.graphics.setColor(0, 0, 0, 1)
	--love.graphics.printf(phrase, 0, centerY, width, "center")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bed, centerX, centerY, 0, 0.5, 0.5, bed:getWidth() / 2, bed:getHeight() / 2)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(currentCat, centerX + xPos * velocity, centerY + yPos * velocity, rot * amplitude * math.sin(sine/rotVelocity), cat.size.x, cat.size.y, imgWidth / 2, imgHeight / 2)

end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		-- left click
		local hover = onCat(x, y)
		if not hover or cat.state ~= state.sleep then return end

		wakeUp()
	end
end

function love.mousereleased(x, y, button, istouch)

end

function love.mousefocus(focus)
	if focus then
		--print("on focus")
	else
		--print("not on focus")
	end
end