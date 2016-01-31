lg = love.graphics

function createTube()
  local t = {}
  t.body = love.physics.newBody(world, 300, love.math.random(0, 100), "dynamic")
  t.shape = love.physics.newRectangleShape(0,0,25,100)
  t.fixture = love.physics.newFixture(t.body, t.shape, 1)
  t.body:setInertia(250)
  t.body:applyForce(-6000, 800)
  t.body:applyTorque(math.random(40000, 60000))
  t.timer = 0
  return t
end

function love.load()
  love.physics.setMeter(64)
  gameover = 0
  world = love.physics.newWorld(0, 9.81 * 64, true)
  player = {}
  tubes = {}
  player.timer = 0
  player.x = 100
  player.y = 100
  player.dy = 0
  player.body = love.physics.newBody(world, 140, 100, "dynamic")
  player.shape = love.physics.newRectangleShape(0,0,17, 12)
  player.fixture = love.physics.newFixture(player.body, player.shape, 5)

  assets = {}
  assets.Tileset = lg.newImage('img/sprite.png')

  timer = 0

  local tilesetW, tilesetH = assets.Tileset:getWidth(), assets.Tileset:getHeight()
  assets.BgQuad = lg.newQuad(0,0,144,256, tilesetW, tilesetH)

  assets.Bird1 = lg.newQuad(3, 491, 17, 12, tilesetW, tilesetH)
  assets.Bird2 = lg.newQuad(31, 491, 17, 12, tilesetW, tilesetH)
  assets.Bird3 = lg.newQuad(60, 491, 17, 12, tilesetW, tilesetH)

  assets.Tube = lg.newQuad(0, 323, 25, 100, tilesetW, tilesetH)
end

function love.draw()
  timer = timer + 1
  player.timer = timer
  love.graphics.push()
  love.graphics.scale(2, 2)
  lg.draw(assets.Tileset, assets.BgQuad, 288 - timer % 288, 0)
  lg.draw(assets.Tileset, assets.BgQuad, 288 - timer % 288 + 144, 0)
  lg.draw(assets.Tileset, assets.BgQuad, (288 - timer % 288) - 144, 0)
  lg.draw(assets.Tileset, assets.BgQuad, (288 - timer % 288) - 288, 0)
  drawPlayer(player, 100, 100)

  for k, t in pairs(tubes) do
    lg.draw(assets.Tileset, assets.Tube, t.body:getX(), t.body:getY(), t.body:getAngle())
  end


  if timer < 80 then
    lg.setColor(0,0,0,255)
    lg.rectangle("fill", 0, 0, 288, 256)
    lg.setColor(255,255,255,255)
    lg.print("Girls are Praying",90,100)
    lg.print("Press Space to Fly",80,140)
    lg.print("Dodge the Tubes",85,160)
  end

  if gameover > 0 then
    lg.setColor(0,0,0,255)
    lg.rectangle("fill", 0, 0, 288, 256)
    lg.setColor(255,255,255,255)
    lg.print("You Lose",90,100)
    lg.print(tostring(gameover),90,120)
    lg.print("Reopen the game to restart",40,140)
  end

  love.graphics.pop()
end

function drawPlayer(player)
  local t = player.timer
  local n = math.floor(t / 20) % 4
  local x, y = player.x, player.y
  local q
  if (n == 0) then
    q = assets.Bird1
  elseif (n == 1) then
    q = assets.Bird2
  elseif (n == 2) then
    q = assets.Bird3
  else
    q = assets.Bird2
  end

  local vx, vy = player.body:getLinearVelocity()
  local r = math.atan(vy/40) * 0.1

  lg.draw(assets.Tileset, q, player.body:getX(), player.body:getY(), r, 1, 1, 8.5, 6)
  lg.print("" .. math.floor(timer / 20), 0, 0)
end

function love.update(dt)
  world:update(dt)
  updatePlayer(player)

  if timer % 50 == 0 and timer > 90 then
    table.insert(tubes, createTube())
  end

  if timer < 90 then
    player.body:setPosition(140, 100)
    player.body:setLinearVelocity(0, 0)
  end

  for k, t in pairs(tubes) do
    t.body:applyForce(0, -300)
  end
end

function updatePlayer(player)
  if love.keyboard.isDown("space") then
    player.body:applyForce(0, -300)
    if timer % 1 == 0 then
      player.timer = player.timer + 1
    end
  end

  if player.body:getY() < 0 or player.body:getY() > 256 or player.body:getX() < 0 then
    if gameover == 0 then
      gameover = math.floor(timer / 20)
    end
  end
end
