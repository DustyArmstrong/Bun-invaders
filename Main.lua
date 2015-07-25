love.graphics.setDefaultFilter('nearest', 'nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage('space invader.png')
particle_systems = {}
particle_systems.list = {}
particle_systems.img = love.graphics.newImage('particle.png')

function particle_systems:spawn(x, y)
  local ps = {}
  ps.x = x + 20
  ps.y = y + 35
  ps.ps = love.graphics.newParticleSystem(particle_systems.img, 32)
  ps.ps:setParticleLifetime(2, 4)
  ps.ps:setEmitterLifetime(2)
  ps.ps:setEmissionRate(5)
  ps.ps:setSizeVariation(1)
  ps.ps:setLinearAcceleration(-20, -20, 20, 20)
  ps.ps:setColors(255, 255, 255, 255, 255, 100, 255, 255)
  table.insert(particle_systems.list, ps)
end

function particle_systems:draw()
  for _, v in pairs(particle_systems.list) do
    love.graphics.draw(v.ps, v.x, v.y)
  end
end

function particle_systems:update(dt)
  for _, v in pairs(particle_systems.list) do
    v.ps:update(dt)
  end
end

function checkCollisions(enemies, bullets)
	for i,en in pairs(enemies)do 
		for _,bul in pairs(bullets)do 
			if bul.y <= en.y + en.height and bul.x > en.x and bul.x < en.x + en.width then 
				particle_systems:spawn(en.x, en.y)
				table.remove(enemies, i)
				table.remove(player.bullets, i)
				love.audio.play(boom)
			end 
		end 
	end 
end 

function map_collision()
	if player.x < 0  then 
		player.x = 0
		elseif player.x > 730 then 
			player.x = 730
	end 
end 

function love.load()
--game over
game_over = false 
game_win = false
-- music 
boom = love.audio.newSource('boom.wav', "stream")
bgmusic = love.audio.newSource('ass bleed.wav', "stream")
bgmusic:setLooping(true)
love.audio.play(bgmusic)
-- static image loading
	background = love.graphics.newImage('map.png')
	gameoverscn = love.graphics.newImage('fug.png')
	gamewinscn = love.graphics.newImage('thumbup.png')
-- player loading
player = {}
player.x = 0
player.y = 530
player.bullets = {}
player.cooldown = 20
player.speed = 5
player.image = love.graphics.newImage('player.png')
player.firesound = love.audio.newSource('pew.wav')
player.fire = function()
	love.audio.play(player.firesound)
	if player.cooldown <= 0 then 
	player.cooldown = 20
	bullet = {}
	bullet.x = player.x + 29
	bullet.y = player.y + 20
	table.insert(player.bullets, bullet)
	end 
end 
	for i = 0, 9 do 
	enemies_controller:spawnEnemy(i * 83, 0)
end 
	for i = 0, 9 do 
		enemies_controller:spawnEnemy(i * 83, -100)
	end 
	
end 

function enemies_controller:spawnEnemy(x, y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = 48
	enemy.height = 48
	enemy.bullets = {}
	enemy.cooldown = 20
	enemy.speed = .5
	table.insert (self.enemies, enemy)
end 

function enemy:fire()
	if self.cooldown <= 0 then 
		self.cooldown = 20
		bullet = {}
		bullet.x = self.x + 35
		bullet.y = self.y 
		table.insert(self.bullets, bullet)
	end 
end

function love.update(dt)
	map_collision()
	particle_systems:update(dt)
	player.cooldown = player.cooldown - 1 
	if love.keyboard.isDown("right") then 
		player.x = player.x + player.speed
		elseif love.keyboard.isDown("left")then 
			player.x = player.x - player.speed
		end 
	if love.keyboard.isDown(" ")then 
		player.fire()
		end 

	if #enemies_controller.enemies == 0 then
		game_win = true
	end 

	for _,en in pairs(enemies_controller.enemies) do 
		if en.y >= love.graphics.getHeight() then 
			game_over = true
		end 
		en.y = en.y + 1 * en.speed
	end 
	for i,bul in ipairs(player.bullets) do 
		if bul.y < -10 then 
			table.remove(player.bullets, i)
		end 
		bul.y = bul.y - 10
	end 

	checkCollisions(enemies_controller.enemies, player.bullets)
end 

function love.draw() 
	-- game over screen
	if game_over then 
		love.graphics.print("Game Over!", 320, 500, 0, 2, 2)
		love.graphics.draw(gameoverscn, 150, 120)
		return 
		elseif game_win then 
			love.graphics.print("You did it!", 50, 50, 0, 2, 2)
			love.graphics.draw(gamewinscn, 150, 0)
		return 
	end 
	-- draw the background 
    love.graphics.draw(background, 0, 0, 0, 2, 1.8)
	--draw the player      r.    g.   b. values for both player/enemy
	love.graphics.setColor(255, 255, 255, 255)
	--                                                  rot size
	love.graphics.draw(player.image, player.x, player.y, 0, 7)

	--draw the enemies 
	for i,en in pairs(enemies_controller.enemies) do 
		love.graphics.draw(enemies_controller.image, en.x, en.y, 0, 5)
	end 

	--draw the bullets
	
	for _,bul in pairs (player.bullets) do
		love.graphics.rectangle("fill", bul.x, bul.y, 10, 10)
		love.graphics.setColor(255, 255, 255, 255)
	end 
		particle_systems:draw()
end 
