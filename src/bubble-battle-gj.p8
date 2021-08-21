pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- bubble battle
-- by peanutsfly

game = {}
game.credits = {
  art = "peanutsfly",
  music_by = "@grubermusic",
  programming = "peanutsfly",
  sounds = "peanutsfly"
}
game.version = "1.0"
game.debug = false

function _init()
  t=0

  cartdata("peanutsfly_bubblebattle_0")

  palt(0,false)
	 palt(15,true)

  add_title()
  add_tutorial()
  add_achievments()
  add_credits()
  add_game()
  add_score()

  sc:init("title")
end

function _update60()
  t+=1
  sc:update()
end

function _draw()
  sc:draw()
--  print("memory: "..(stat(0)/2048*100).."%",4,24,7)
--  print("cpu: "..stat(1),4,32,7)
--  print("fps: "..stat(7),4,40,7)
end

player = {
  oxygen = 50,
  oxygen_limit = 75,
  oxygen_decrease = 1/20,
  oxygen_warning = 20,
  poison_limit = 10,
  poison_decrease = 1/120,
  poison_warning = 6,
  position = {x=63, y=79},
  radius = 8,
  score_increase = 1/2,
  speed = 1,
  death_counter = 60
}
bullet = {
  oxygen = 4,
  radius = 5,
  speed = 2
}
oxygen = {
  oxygen = {6, 10},
  radius = {5, 8},
  speed = {1, 1},
  repetition = {90, 60, 45, 45, 30, 10}
}
poison = {
  poison = {3, 5},
  radius = {5, 8},
  speed = {1, 1},
  repetition = {120, 90, 45, 30, 15, 5}
}
nuclear = {
  radius = 8,
  speed = 1,
  repetition = {600, 450, 200, 100, 50, 25}
}
direction = {
  none = {x=0, y=0},
  left = {x=-1, y=0},
  right = {x=1, y=0},
  up = {x=0, y=-1},
  down = {x=0, y=1},
  upleft = {x=-1, y=-1},
  upright = {x=1, y=-1},
  downleft = {x=-1, y=1},
  downright = {x=1, y=1}
}
tasks = {
  achiev1 = 200,
  achiev2 = 20,
  achiev3 = 5
}

-->8
-- semiclasses
-- scene controller
sc = {}

sc.current = nil
sc.scenes = {}

function sc:init(name)
  if self.current then
    if self.current.unload then
      self.current:unload()
    end
  end
  self.current = self.scenes[name]
  self.current:init()
end

function sc:update()
  self.current:update()
end

function sc:draw()
  self.current:draw()
end

function sc:add(name,scene)
  self.scenes[name] = scene
end

-- menu
menu = {}

menu.current = nil
menu.options = {}

menu.spacing = 8
menu.c_select = 11
menu.c_unselect = 13
menu.sfx_press = 1
menu.sfx_switch = 2

function menu:init()
  if #self.options >= 1 then
    self.current = 1
    self.options[self.current].selected = true
  end
end

function menu:update()
  local list = self.options
  if btnp(3) then
    play_sfx(self.sfx_switch)
    self.current += 1
    if self.current <= #list then
      list[self.current-1].selected = false
      list[self.current].selected = true
    else
      self.current = 1
      list[#list].selected = false
      list[self.current].selected = true
    end
  elseif btnp(2) then
    play_sfx(self.sfx_switch)
    self.current -= 1
    if self.current >= 1 then
      list[self.current+1].selected = false
      list[self.current].selected = true
    else
      self.current = #list
      list[1].selected = false
      list[self.current].selected = true
    end
  end
  if btnp(4) or btnp(5) then
    play_sfx(self.sfx_press)
    list[self.current]:reference()
  end
end

function menu:draw(plc_y)
  for opt in all(self.options) do
    local c = self.c_unselect
    if opt.selected then
      c = self.c_select
    end
    print(opt.label,hcenter(opt.label),plc_y,c)
    plc_y += self.spacing
  end
end

function menu:add(label,reference)
  add(self.options,{
      label=label,
      reference=reference,
      selected=false
    })
end

function menu:reset()
  menu.current = nil
  menu.options = {}
end

-- circle shape
circle = {}

function circle:new(x,y,r)
  local c = {}
  setmetatable(c, self)
  self.__index = self

  c.x = x
  c.y = y
  c.r = r

  return c
end

function circle:draw(c)
  if game.debug then
    circ(self.x,self.y,self.r,c)
  end
end

function circle:is_colliding(c)
  local dx = c.x-self.x
  local dy = c.y-self.y
  local distance = sqrt(dx*dx+dy*dy)

  return distance < self.r + c.r
end

-->8
-- scenes
function add_title()
  local title = {}

  function title:init()
    music(6, 2400)
    menu:add("play", self.play)
    menu:add("achievments", self.achievments)
    menu:add("credits", self.credits)
    menu:init()
  end

  function title:update()
  	update_map()
    menu:update()
  end

  function title:draw()
    cls(1)
    draw_map_title()
    local control_info = "x+c"
    print(control_info, hcenter(control_info), 115, 6)
    menu:draw(87)
  end

  function title:unload()
    menu:reset()
  end

  function title:play()
    sc:init("tutorial")
  end

  function title:achievments()
    sc:init("achievments")
  end

  function title:credits()
    sc:init("credits")
  end

  sc:add("title",title)
end

function add_tutorial()
  local tutorial = {}

  function tutorial:init()
    menu:add("continue", self.play)
    menu:init()
  end

  function tutorial:update()
    update_map()
    menu:update()
  end

  function tutorial:draw()
    cls(1)
    draw_map()
    create_window(0, 8, 127, 111)
    text_formatting("introduction", 18, {}, 7, 16, 16)
    local color = 15
    sspr(0, 72, 48, 16, 7, 31)
    print("move and fire o2", 58, 33, color)
    print("take and give o2", 58, 41, color)
    sspr(56, 40, 64, 24, 62, 52)
    print("collect o2", 7, 53, color)
    print("avoid poison", 7, 61, color)
    print("avoid bombs", 7, 69, color)
    sspr(0, 40, 56, 16, 6, 84)
    print("pay attention", 65, 84, color)
    print("to your limits!", 65, 92, color)
    menu:draw(105)
  end

  function tutorial:unload()
    menu:reset()
  end

  function tutorial:play()
    sc:init("game")
  end

  sc:add("tutorial", tutorial)
end

function add_achievments()
  local achievments = {}

  function achievments:init()
    menu:add("menu", self.title)
    menu:init()
  end

  function achievments:update()
    update_map()
    menu:update()
  end

  function achievments:draw()
    cls(1)
    draw_map()
    create_window(0, 8, 127, 111)
    text_formatting("achievments", 20, {}, 7, 16, 16)
    self:draw_achievments()
    menu:draw(103)
  end

  function achievments:unload()
    menu:reset()
  end

  function achievments:draw_achievments()
  	if dget(1) == 1 then
  		sspr(48,0,16,16,16,32)
  	else
  		sspr(32,0,16,16,16,32)
  	end
  	if dget(2) == 1 then
  		sspr(64,0,16,16,16,54)
  	else
  		sspr(32,0,16,16,16,54)
  	end
  	if dget(3) == 1 then
  		sspr(80,0,16,16,16,76)
  	else
  		sspr(32,0,16,16,16,76)
  	end
  	local achiev1 = "collect "..tasks.achiev1.." oxygen\nin a run"
  	local achiev2 = "collect "..tasks.achiev2.." poison\nin a run"
  	local achiev3 = "destroy "..tasks.achiev3.." bombs\nin a run"
  	print(achiev1,36,34,7)
  	print(achiev2,36,56,7)
  	print(achiev3,36,78,7)
  end

  function achievments:title()
    sc:init("title")
  end

  sc:add("achievments", achievments)
end

function add_credits()
  local credits = {}

  function credits:init()
    menu:add("menu",self.title)
    menu:init()
  end

  function credits:update()
    update_map()
    menu:update()
  end

  function credits:draw()
    cls(1)
    draw_map()
    create_window(0, 8, 127, 111)
    local credits_text = {
      "art by "..game.credits.art,
      "music by "..game.credits.music_by,
      "programming by "..game.credits.programming,
      "sounds by "..game.credits.sounds
    }
    text_formatting("credits", 20, credits_text, 7, 16, 16)
    menu:draw(103)
  end

  function credits:unload()
    menu:reset()
  end

  function credits:title()
    sc:init("title")
  end

  sc:add("credits",credits)
end

function add_game()
  gameplay = {}

  function gameplay:init()
    music(6, 2400)
    p:init()
  end

  function gameplay:update()
    update_map()
    effects:update()
    cc:update()
    oc:update()
    pc:update()
    nc:update()
    bc:update()
    p:update()
  end

  function gameplay:draw()
    cls(1)
    draw_map_game()
    effects:draw()
    oc:draw()
    pc:draw()
    nc:draw()
    bc:draw()
    p:draw()
    self:gui()
  end

  function gameplay:unload()
    effects:reset()
    oc:reset()
    pc:reset()
    nc:reset()
    bc:reset()
  end

  function gameplay:gui()
    create_window(0,0,127,20)
    create_window(0,115,127,12)

    local oxygen_gui = "oxygen: "..flr(p.oxygen).."/"..player.oxygen_limit
    local text_c = 7
    if p.oxygen <= player.oxygen_warning then
      text_c = 10
    end
    print(oxygen_gui,hcenter(oxygen_gui),4,text_c)
    text_c = 7
    if p.poison >= player.poison_warning then
      text_c = 10
    end
    local poison_gui = "poison: "..flr(p.poison).."/"..player.poison_limit
    print(poison_gui, hcenter(poison_gui),12,text_c)
    local score_gui = "score: "..flr(p.score/10)*10
    print(score_gui,hcenter(score_gui),119,7)
  end

  sc:add("game",gameplay)
end

function add_score()
  local score = {}

  function score:init()
    music(31, 2400)
    menu:add("retry",self.game)
    menu:add("menu",self.title)
    menu:init()
    highscore = dget(0)
    current_score = 0
  end

  function score:update()
    highscore = dget(0)
    current_score = flr(p.score/10)*10
    if current_score > highscore then
      highscore = current_score
      dset(0, highscore)
    end
    self:unlock_achievments()
    update_map()
    menu:update()
  end

  function score:draw()
    cls(1)
    draw_map()
    create_window(0, 8, 127, 111)
    local score_text = {
      "highscore: "..highscore,
      "score: "..current_score
    }
    local collected_text = {
      "oxygen collected: "..p.collected_oxygen,
      "poison collected: "..p.collected_poison,
      "bombs destroyed: "..p.bombs_destroyed
    }
    text_formatting("score", 16, score_text, 7, 14, 12)
    text_formatting("", 48, collected_text, 7, 12, 12)
    menu:draw(99)
  end

  function score:unload()
    menu:reset()
  end

  function score:unlock_achievments()
    if p.collected_oxygen >= tasks.achiev1 then
      dset(1, 1)
    end
    if p.collected_poison >= tasks.achiev2 then
      dset(2, 1)
    end
    if p.bombs_destroyed >= tasks.achiev3 then
      dset(3, 1)
    end
  end

  function score:game()
    sc:init("game")
  end

  function score:title()
    sc:init("title")
  end

  sc:add("score", score)
end
-->8
-- tools
function hcenter(txt)
  return 64-#txt*2
end

function bool_to_int(val)
  return val and 1 or 0
end

function play_sfx(source)
  if source then
    sfx(source)
  end
end

function in_screen(x,y,range_x,range_y)
  local range_x = range_x or {0,127}
  local range_y = range_y or {0,127}
  local result = {x=true,y=true}
  if x < range_x[1] or x > range_x[2] then
    result.x = false
  end
  if y < range_y[1] or y > range_y[2] then
    result.y = false
  end
  return result.x, result.y
end

function create_window(x, y, w, h)
  local x1, y1 = x, y
  local x2, y2 = x+w, y+h
  local line_x1 = ceil(x+(w-4)/2-(h-4)/2)
  local line_x2 = flr(x+(w-4)/2+(h-4)/2)

  rect(x1,y1,x2,y2,7)
  rect(x1+1,y1+1,x2-1,y2-1,0)
  rectfill(x1+2,y1+2,line_x2,y2-2,1)
  rectfill(line_x2+1,y1+2,x2-2,y2-2,2)
  for i=y2-2,y1+2,-1 do
    line(line_x1,y1+2,line_x2+1,i,2)
    line_x1+=1
  end
end

function text_formatting(title, plc_y, credits, color, spacing_title, spacing)
  local spacing_title = spacing_title or 12
  local spacing = spacing or 8
  print(title, hcenter(title), plc_y, color)
  line(hcenter(title), plc_y+6, hcenter(title)+#title*4-2, plc_y+6, 7)
  plc_y += spacing_title
  for line in all(credits) do
    print(line, hcenter(line), plc_y, color)
    plc_y += spacing
  end
end
-->8
-- entities
-- player
p = {}

function p:init()
  p.oxygen = player.oxygen
  p.poison = 0
  p.score = 0
  p.collected_oxygen = 0
  p.collected_poison = 0
  p.bombs_destroyed = 0
  p.motion = {x=0, y=0}
  p.shape = circle:new(player.position.x, player.position.y, player.radius)
  p.lost = false
  p.dead = false
  p.dead_counter = player.death_counter
end

function p:update()
  if not self.dead then
    self:counter()
    self:control()
    self:motion_update()
    self:action_update()
    if self.lost then
      explode(p.shape.x, p.shape.y, player.death_counter)
      p.dead = true
    end
  else
    self.dead_counter-=1
    if self.dead_counter <=0 then
      sc:init("score")
    end
  end
end

function p:draw()
  if not p.dead then
    sspr(80, 16, 16, 16, self.shape.x-self.shape.r, self.shape.y-self.shape.r)
    self.shape:draw(8)
  end
end

function p:counter()
  self.oxygen -= player.oxygen_decrease
  if self.oxygen < 1 or self.poison >= player.poison_limit then
    self.lost = true
  end
  if flr(self.poison) > 0 then
    self.poison -= player.poison_decrease
  end
  self.score += player.score_increase
end

function p:control()
  self.motion.x = -bool_to_int(btn(0))+bool_to_int(btn(1))
  self.motion.y = -bool_to_int(btn(2))+bool_to_int(btn(3))
end

function p:motion_update(var)
  local pred_x = self.shape.x + self.motion.x * player.speed
  local pred_y = self.shape.y + self.motion.y * player.speed

  x_is_fine, y_is_fine = in_screen(pred_x, pred_y, {self.shape.r, 127-self.shape.r},{self.shape.r+21, 127-self.shape.r-12})

  if x_is_fine then
    self.shape.x += self.motion.x * player.speed
  end

  if y_is_fine then
    self.shape.y += self.motion.y * player.speed
  end
end

function p:action_update()
  if btnp(5) or btnp(4) then
    if self.oxygen - bullet.oxygen > 1 then
    	sfx(3)
      self.oxygen -= bullet.oxygen
      bc:spawn_bullet(self.shape.x, self.shape.y, direction.left)
      bc:spawn_bullet(self.shape.x, self.shape.y, direction.right)
      bc:spawn_bullet(self.shape.x, self.shape.y, direction.up)
      bc:spawn_bullet(self.shape.x, self.shape.y, direction.down)
    end
  end
end

-- bullet controller
bc = {}

bc.bullets = {}

function bc:update()
  for b in all(self.bullets) do
    b.shape.x += b.vector.x * bullet.speed
    b.shape.y += b.vector.y * bullet.speed
    local x_is_fine, y_is_fine = in_screen(b.shape.x, b.shape.y, {-b.shape.r, 127+b.shape.r}, {-b.shape.r+21, 127+b.shape.r-12})
    if not x_is_fine or not y_is_fine then
      b.destruct_me = true
    end
  end
  self:destruct_bullets()
end

function bc:draw()
  local offset = 3
  for b in all(self.bullets) do
    sspr(0, 16, 16, 16, b.shape.x-offset-b.shape.r, b.shape.y-offset-b.shape.r)
    b.shape:draw(8)
  end
end

function bc:spawn_bullet(x, y, vector)
  local b = {}
  b.shape = circle:new(x, y, bullet.radius)
  b.vector = vector
  b.destruct_me = false
  add(self.bullets, b)
end

function bc:destruct_bullets()
  for i=#self.bullets,1,-1 do
    if self.bullets[i].destruct_me then
      deli(self.bullets, i)
    end
  end
end

function bc:reset()
  bc.bullets = {}
end

-- oxygen controller
oc = {}

oc.bubbles = {}

function oc:update()
  for b in all(self.bubbles) do
    b.shape.x += b.vector.x * oxygen.speed[b.state]
    b.shape.y += b.vector.y * oxygen.speed[b.state]

    self:collision_handler(b)

    local x_is_fine, y_is_fine = in_screen(b.shape.x, b.shape.y, {-16, 143}, {-16, 143})
    if not x_is_fine or not y_is_fine then
      b.destruct_me = true
    end
  end
  self:destruct_oxygen()
end

function oc:draw()
  for b in all(self.bubbles) do
    local sx, offset = 0, 3
    if b.state == 2 then
      sx, offset = 16, 0
    end
    sspr(sx, 16, 16, 16, b.shape.x-offset-b.shape.r, b.shape.y-offset-b.shape.r)
    b.shape:draw(8)
  end
end

function oc:change_state(bubble)
  bubble.state += 1
  if bubble.state > 2 then
    bubble.destruct_me = true
    explode(bubble.shape.x, bubble.shape.y, 30)
  else
    bubble.shape.r = oxygen.radius[bubble.state]
  end
end

function oc:collision_handler(bubble)
  if bubble.shape:is_colliding(p.shape) then
    sfx(4)
    p.oxygen = min(p.oxygen + oxygen.oxygen[bubble.state], player.oxygen_limit)
    p.collected_oxygen += oxygen.oxygen[bubble.state]
    bubble.destruct_me = true
  end
  for bullet in all(bc.bullets) do
    if bubble.shape:is_colliding(bullet.shape) then
      sfx(5)
      bullet.destruct_me = true
      self:change_state(bubble)
    end
  end
end

function oc:spawn_oxygen(x, y, vector, state)
  local b = {}
  b.state = state
  b.shape = circle:new(x, y, oxygen.radius[b.state])
  b.vector = vector
  b.destruct_me = false
  add(self.bubbles, b)
end

function oc:destruct_oxygen()
  for i=#self.bubbles,1,-1 do
    if self.bubbles[i].destruct_me then
      deli(self.bubbles, i)
    end
  end
end

function oc:reset()
  self.bubbles = {}
end

-- poison controller
pc = {}

pc.bubbles = {}

function pc:update()
  for b in all(self.bubbles) do
    b.shape.x += b.vector.x * poison.speed[b.state]
    b.shape.y += b.vector.y * poison.speed[b.state]

    self:collision_handler(b)

    local x_is_fine, y_is_fine = in_screen(b.shape.x, b.shape.y, {-16, 143}, {-16, 143})
    if not x_is_fine or not y_is_fine then
      b.destruct_me = true
    end
  end
  self:destruct_poison()
end

function pc:draw()
  for b in all(self.bubbles) do
    local sx, offset = 32, 3
    if b.state == 2 then
      sx, offset = 48, 0
    end
    sspr(sx, 16, 16, 16, b.shape.x-offset-b.shape.r, b.shape.y-offset-b.shape.r)
    b.shape:draw(8)
  end
end

function pc:change_state(bubble)
  bubble.state += 1
  if bubble.state > 2 then
    bubble.destruct_me = true
    explode(bubble.shape.x, bubble.shape.y, 30)
  else
    bubble.shape.r = poison.radius[bubble.state]
  end
end

function pc:collision_handler(bubble)
  if bubble.shape:is_colliding(p.shape) then
    sfx(4)
    p.poison = p.poison + poison.poison[bubble.state]
    p.collected_poison += poison.poison[bubble.state]
    bubble.destruct_me = true
  end
  for bullet in all(bc.bullets) do
    if bubble.shape:is_colliding(bullet.shape) then
      sfx(5)
      bullet.destruct_me = true
      self:change_state(bubble)
    end
  end
end

function pc:spawn_poison(x, y, vector, state)
  local b = {}
  b.state = state
  b.shape = circle:new(x, y, poison.radius[b.state])
  b.vector = vector
  b.destruct_me = false
  add(self.bubbles, b)
end

function pc:destruct_poison()
  for i=#self.bubbles,1,-1 do
    if self.bubbles[i].destruct_me then
      deli(self.bubbles, i)
    end
  end
end

function pc:reset()
  self.bubbles = {}
end

-- nuclear controller
nc = {}

nc.bubbles = {}

function nc:update()
  for b in all(self.bubbles) do
    b.shape.x += b.vector.x * nuclear.speed
    b.shape.y += b.vector.y * nuclear.speed

    self:collision_handler(b)

    local x_is_fine, y_is_fine = in_screen(b.shape.x, b.shape.y, {-16, 143}, {-16, 143})
    if not x_is_fine or not y_is_fine then
      b.destruct_me = true
    end
  end
  self:destruct_nuclear()
end

function nc:draw()
  for b in all(self.bubbles) do
    sspr(64, 16, 16, 16, b.shape.x-b.shape.r, b.shape.y-b.shape.r)
    b.shape:draw(8)
  end
end

function nc:collision_handler(bubble)
  if bubble.shape:is_colliding(p.shape) then
    sfx(4)
    p.lost = true
    bubble.destruct_me = true
  end
  for bullet in all(bc.bullets) do
    if bubble.shape:is_colliding(bullet.shape) then
      sfx(5)
      bullet.destruct_me = true
      bubble.destruct_me = true
      explode(bubble.shape.x, bubble.shape.y, 30)
      p.bombs_destroyed += 1
    end
  end
end

function nc:spawn_nuclear(x, y, vector)
  local b = {}
  b.shape = circle:new(x, y, nuclear.radius)
  b.vector = vector
  b.destruct_me = false
  add(self.bubbles, b)
end

function nc:destruct_nuclear()
  for i=#self.bubbles,1,-1 do
    if self.bubbles[i].destruct_me then
      deli(self.bubbles, i)
    end
  end
end

function nc:reset()
  self.bubbles = {}
end

-- content controller
cc = {}

cc.difficulty = 1

cc.possible_dir = {
  direction.left, direction.right, direction.up, direction.down,
  direction.upleft, direction.upright, direction.downleft, direction.downright
}

function cc:update()
  cc:set_difficulty()
  cc:spawn_oxygen()
  cc:spawn_poison()
  cc:spawn_nuclear()
end

function cc:set_difficulty()
  if p.score > 250 then
    self.difficulty = 2
  elseif p.score > 500 then
    self.difficulty = 3
  elseif p.score > 1000 then
    self.difficulty = 4
  elseif p.score > 2000 then
    self.difficulty = 5
  elseif p.score > 3000 then
    self.difficulty = 6
  end
end

function cc:spawn_oxygen()
  if t%(oxygen.repetition[self.difficulty])==0 then
    local position, vector = self:calculate_params()
    local state = self:calculate_state(3, 1)
    oc:spawn_oxygen(position.x, position.y, vector, state)
  end
end

function cc:spawn_poison()
  if t%(poison.repetition[self.difficulty])==0 then
    local position, vector = self:calculate_params()
    local state = self:calculate_state(3, 1)
    pc:spawn_poison(position.x, position.y, vector, state)
  end
end

function cc:spawn_nuclear()
  if t%(nuclear.repetition[self.difficulty])==0 then
    local position, vector = self:calculate_params()
    nc:spawn_nuclear(position.x, position.y, vector)
  end
end

function cc:calculate_params()
  local vector = self.possible_dir[flr(rnd(#self.possible_dir))+1]
  local position = {x=0, y=0}
  if vector == direction.left or vector == direction.upleft or vector == direction.downleft then
    position.x = 135
    position.y = flr(rnd(127))
  elseif vector == direction.right or vector == direction.upright or vector == direction.downright then
    position.x = -8
    position.y = flr(rnd(127))
  elseif vector == direction.up then
    position.x = flr(rnd(127))
    position.y = 135
  elseif vector == direction.down then
    position.x = flr(rnd(127))
    position.y = -8
  end

  return position, vector
end

function cc:calculate_state(ratio, to_ratio)
  local state_rnd = flr(rnd(ratio + to_ratio))+1
  local state = 1
  if state_rnd > ratio then
    state = 2
  end

  return state
end

-->8
-- map
map_slow = 0
map_fast = 0

function update_map()
	map_slow -= 1
	map_fast -= 2
	if map_slow < -127 then
		map_slow = 0
	end
	if map_fast < -127 then
		map_fast = 0
	end
end

function draw_map()
  map(0,0,0,0,16,16)
  map(16,0,map_slow,map_slow,16,16)
  map(16,0,map_slow+128,map_slow,16,16)
  map(16,0,map_slow,map_slow+128,16,16)
  map(16,0,map_slow+128,map_slow+128,16,16)
  map(16,0,-map_slow,-map_slow,16,16)
  map(16,0,-map_slow-128,-map_slow,16,16)
  map(16,0,-map_slow,-map_slow-128,16,16)
  map(16,0,-map_slow-128,-map_slow-128,16,16)
end

function draw_map_game()
	map(0,0,0,0,16,16)
 map(32,0,-map_fast,-map_fast,16,16)
 map(32,0,-map_fast-128,-map_fast,16,16)
 map(32,0,-map_fast,-map_fast-128,16,16)
 map(32,0,-map_fast-128,-map_fast-128,16,16)
 draw_map()
end

function draw_map_title()
	draw_map()
	map(0,16,0,0,16,16)
	map(16,16,0-flr(t/25%2),0-flr(t/25%2),16,16)
	map(32,16,0+flr(t/25%2),0+flr(t/25%2),16,16)
end
-->8
-- recycled
effects = {}

effects.list = {}

function effects:update()
  for effect in all(self.list) do
    effect:update()
  end
end

function effects:draw()
  for effect in all(self.list) do
    effect:draw()
  end
end

function effects:reset()
  effects.list = {}
end

function explode(x, y, timer)
	local aa=rnd(1)
	for i=0,5 do
    local vector = {}
		vector.x=cos(aa+i/6)/4
		vector.y=sin(aa+i/6)/4
		particle(x, y, vector, timer)
	end
end

function particle(x, y, vector, timer)
  local particle = {}
	particle.position = {}
  particle.position.x = x
  particle.position.y = y
  particle.vector = vector
  particle.timer = timer
	particle.sprites = {75, 76, 77, 78}
  particle.speed = 2
	particle.update=function(self)
		self.timer+=-1
		self.position.x += self.vector.x * self.speed
		self.position.y += self.vector.y * self.speed
		if self.timer<=0 then
			del(effects.list,self)
		end
	end
  particle.draw=function(self)
    local sprite = self.sprites[flr(t/15)%#self.sprites+1]
    spr(sprite, self.position.x, self.position.y, 1, 1)
  end
  add(effects.list, particle)
end


__gfx__
ffffffff11111111ffffffffffffffff777777777777777777777777777777777777777777777777777777777777777766666ffffff6666666666fffffff60cc
ffffffff11111111ffffffffffffffff7000000000000007700000000000000770000000000000077000000000000007000006ffff600000000006ffffff60cc
ff7ff7ff11111111fff55ffffff55fff7066666666666607709999999999990770333333333333077066666886666607ccccc06ff60cccccccccc06fffff60cc
fff77fff11111111ff57c5ffff5725ff7066666666666607709999666699990770333366663333077066688008866607cccccc0660c7cccccccccc06ffff60cc
fff77fff11111111ff5cc5ffff5225ff7066665555666607709996000069990770333600006333077066074444406607cccccc0660cc7ccccccccc06ffff60cc
ff7ff7ff11111111fff55ffffff55fff7066656666566607709960cccc06990770336022220633077068477555448607ccccc06ff60cccccccccc06fffff60cc
ffffffff11111111ffffffffffffffff706665666656660770960c7cccc069077036027222206307706845aaaa548607000006ffff6000cccc0006ffffff60cc
ffffffff11111111ffffffffffffffff706665555556660770960cc7ccc069077036022722206307708045aaaa54080766666ffffff660cccc066fffffff60cc
fff6666666666ffffff66ffffff66fff706665555556660770960cccccc069077036022222206307708045a55a540807fffffff666666666ffffffffffff60cc
ff600000000006ffff6006ffff6006ff706665566556660770960cccccc069077036022222206307706845aaaa548607ffffff600000000066ffffffffff60cc
f60cccccccccc06ff60cc06ff60cc06f7066655555566607709960cccc06990770336022220633077068445555448607ffff660ccccccccc066fffffffff60cc
60c7cccccccccc0660c7cc0660cccc067066655555566607709996000069990770333600006333077066044444406607fff600c77cccccccc006ffffffff60cc
60cc7ccccccccc0660cc7c0660cccc067066666666666607709999666699990770333366663333077066688008866607ff600cc777cccccccc006fffffff60cc
60cccccccccccc0660cccc0660cccc067066666666666607709999999999990770333333333333077066666886666607f660ccc7777cccccccc06ffffffff60c
60cccc0000cccc0660cccc0660cccc067000000000000007700000000000000770000000000000077000000000000007f60ccccc777ccccccccc06ffffffff60
60cccc0660cccc0660cccc0660cccc06777777777777777777777777777777777777777777777777777777777777777760cccccc777cccccccccc06ffffffff6
ffffffffffffffffffffff6666ffffffffffffffffffffffffffff6666ffffffffffff8888ffffffffffff6666ffffff60ccccc5e7e5c55cccccc06fcc06ffff
ffffffffffffffffffff66000066ffffffffffffffffffffffff66000066ffffffff88000088ffffffff66000066ffff60ccccc5eeee5ee5ccccc06fcc06ffff
fffffffffffffffffff600cccc006ffffffffffffffffffffff6002222006ffffff8004444008ffffff600cccc006fff60ccccc5eeeeeeee5cccc06fcc06ffff
ffffff6666ffffffff60cccccccc06ffffffff6666ffffffff602222222206ffff804444444408ffff60cccccccc06ff60ccccc5eeeeeee85cccc06fcc06ffff
fffff600006ffffff60c77ccccccc06ffffff600006ffffff60277222222206ff80445555554408ff60c775cc555c06f60cccccc5eeeee85ccccc06fcc06ffff
ffff60cccc06fffff60cc77cccccc06fffff60222206fffff60227722222206ff8045aaaaaa5408ff605e7755eee506f60cccccc5ee88855ccccc06fcc06ffff
fff60c7cccc06fff60ccccc7cccccc06fff6027222206fff602222272222220680445a5a55a5440860c5eee7eee85c0660ccccccc58855ccccccc06fcc06ffff
fff60cc7ccc06fff60cccccccccccc06fff6022722206fff602222222222220680445aa5a5a5440860c5eeeeeee85c0660ccccccc555ccccccccc06fcc06ffff
fff60cccccc06fff60cccccccccccc06fff6022222206fff602222222222220680445a5a5aa5440860c5eeeeee885c06f60ccccccccccccccccc06ffcc06ffff
fff60cccccc06fff60cccccccccccc06fff6022222206fff602222222222220680445a55a5a5440860cc5eeee885cc06ff60ccccccccccccccc066ffcc06ffff
ffff60cccc06fffff60cccccccccc06fffff60222206fffff60222222222206ff8045aaaaaa5408ff60cc5ee885cc06fff600ccccccccccccc006fffcc06ffff
fffff600006ffffff60cccccccccc06ffffff600006ffffff60222222222206ff80445555554408ff60ccc5e85ccc06ffff600ccccccccccc006ffffcc06ffff
ffffff6666ffffffff60cccccccc06ffffffff6666ffffffff602222222206ffff804444444408ffff60ccc55ccc06ffffff660ccccccccc066fffffcc06ffff
fffffffffffffffffff600cccc006ffffffffffffffffffffff6002222006ffffff8004444008ffffff600cccc006ffffffff660000000006fffffffc06fffff
ffffffffffffffffffff66000066ffffffffffffffffffffffff66000066ffffffff88000088ffffffff66000066fffffffffff666666666ffffffff06ffffff
ffffffffffffffffffffff6666ffffffffffffffffffffffffffff6666ffffffffffff8888ffffffffffff6666ffffffffffffffffffffffffffffff6fffffff
60cccc0660cccc0660cccc0660cccc066fffffff60cccc0660cccc0660cccc0660cccc0660cccc0660cccc06fffffffffffffffffffffffffff77fff00000000
60cccc0000ccc06f60cccc0660cccc0006ffffff60cccc0000cccc0660cccc0000cccc06f60ccc0060cccc06fffffffffffffffffff77fffffffffff00000000
60cccccccc0006ff60cccc0660ccccccc06fffff60cccccccccccc0660cccccccccccc06ff6000cc60cccc06fffffffffff77fffffffffffffffffff00000000
60cccccccc066fff60cccc0660cccccccc06ffff60cccccccccccc0660cccccccccccc06fff660cc60cccc06fff77fffff7ff7fff7ffff7f7ffffff700000000
60cccccccc066fff60cccc0660cccccccc06ffff60cccccccccccc0660cccccccccccc06ffff60cc60cccc06fff77fffff7ff7fff7ffff7f7ffffff700000000
60cccccccc0006ff60cccc0660ccccccc06fffff60cccccccccccc06f60cccccccccc06ffffff60cf60cc06ffffffffffff77fffffffffffffffffff00000000
60cccc0000ccc06f60cccc0660cccc0006ffffff60cccc0000cccc06ff600000000006ffffffff60ff6006fffffffffffffffffffff77fffffffffff00000000
60cccc0660cccc0660cccc0660cccc066fffffff60cccc0660cccc06fff6666666666ffffffffff6fff66ffffffffffffffffffffffffffffff77fff00000000
faafafafafaffaafaaafaaffffffffffaaffaaafffafaaafaaaffffffffffffff77fffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
afafafafafafafffafffafaffafffffffaffafaffaffffafafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
afaffaffaaafafffaaffafaffffffffffaffaaaffaffffafaaaffffffffffff7ffff7fffffffffffffffffffffffffffffffffffffffffffffffffff00000000
afafafafffafafafafffafaffafffffffaffafaffaffffafffaffffffffffff7ffff7fffffffffffffffffffff6666ffffffffffffffffffffffffff00000000
aaffafafaaafaaafaaafafafffffffffaaafaaafafffffafaaafffffff77fffffffffffff77fffffffffffff66000066ffffffffffffffffffffffff00000000
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77ffffffffffffffffffff600cccc006fffffffffffffffffffffff00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffff7fffffffff7ffff7fffffffff60cccccccc06ffffffffffff6666ffffff00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffff7fffffffff7ffff7ffffffff60c77ccccccc06ffffffffff600006fffff00000000
ff777ff77f777ff77ff77f77ffffffffff777fff7f77ff777ffffffffffffffffffffffffffffffffffff60cc77cccccc06fffffffff60cccc06ffff00000000
ff7f7f7f7ff7ff7fff7f7f7f7ff7ffffff7f7ff7fff7ff7f7fffffffff77fffffffffffff77ffffff7ff60ccccc7cccccc06ffff7ff60c7cccc06fff00000000
ff777f7f7ff7ff777f7f7f7f7fffffffff7f7ff7fff7ff7f7fffffffffffffffffffffffffffffff77ff60cccccccccccc06fff77ff60cc7ccc06fff00000000
ff7fff7f7ff7ffff7f7f7f7f7ff7ffffff7f7ff7fff7ff7f7ffffffffffffffffffffffffffffff777ff60cccccccccccc06ff777ff60cccccc06fff00000000
ff7fff77ff777f77ff77ff7f7fffffffff777f7fff777f777fffffffffffffffffffffffffffffff77ff60cccccccccccc06fff77ff60cccccc06fff00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77fffffffffffff77ffffff7fff60cccccccccc06fffff7fff60cccc06ffff00000000
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60cccccccccc06ffffffffff600006fffff00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffff7fffffffff7ffff7fffffffff60cccccccc06ffffffffffff6666ffffff00000000
000000000000000000000000000000000000000000000000000000007ffff7fffffffff7ffff7ffffffffff600cccc006fffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffff77ffffffffffffffffffff66000066ffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ff77fffffffffffff77fffffffffffffff6666ffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffff7ffff7ffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffff7ffff7ffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffff77ffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff77777ffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff777f777fffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff77fff77fffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff77fff77fffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff77777ffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
f77777fffffff77777ffffffffffff7f7fff7ff77fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
777ff77fffff77ff777fffff7fffff7f7ff7ff7fffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
77fff77fffff77fff77ffff777fffff7fff7ff7fffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
777ff77fffff77ff777fffff7fffff7f7ff7ff7fffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
f77777fffffff77777ffffffffffff7f7f7ffff77fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff77777ffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff77fff77fffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff77fff77fffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff777f777fffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffff77777ffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111551111111111111111111111111111111111111111111111111111111111111155111111111111111111
11111111111111111111111111111111111111111115725111111111111111111111111111111111111111111111111111111111111572511111111111111111
11111111111111111111111111111111111111111115225111111111111111111111111111111111111111111111111111111111111522511111111111111111
11111111111111111111111111111111111111111111551111111111111111111111111111111111111111111111111111111111111155111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111116666666666111111661111116611111166666666661111116666666666111111661111111111111166666666661111111111111111111
11111111111111111160000000000611116006111160061111600000000006111160000000000611116006111111111111600000000006111111111111551111
1111111111111111160cccccccccc061160cc061160cc061160cccccccccc061160cccccccccc061160cc06111111111160cccccccccc0611111111115725111
111111111111111160c7cccccccccc0660c7cc0660cccc0660c7cccccccccc0660c7cccccccccc0660c7cc061111111160c7cccccccccc061111111115225111
111111111111111160cc7ccccccccc0660cc7c0660cccc0660cc7ccccccccc0660cc7ccccccccc0660cc7c061111111160cc7ccccccccc061111111111551111
111111111111111160cccccccccccc0660cccc0660cccc0660cccccccccccc0660cccccccccccc0660cccc061111111160ccccccccccc0611111111111111111
111111111111111160cccc0000cccc0660cccc0660cccc0660cccc0000cccc0660cccc0000cccc0660cccc061111111160cccc00000006111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc061111111160cccc06666661111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc061111111160cccc06611111111111111111111111
111111111111111160cccc0000ccc06160cccc0660cccc0660cccc0000ccc06160cccc0000ccc06160cccc061111111160cccc00061111111111111111111111
111111111111111160cccccccc00061160cccc0660cccc0660cccccccc00061160cccccccc00061160cccc061111111160ccccccc06111111111111111111111
111111111111111160cccccccc06611160cccc0660cccc0660cccccccc06611160cccccccc06611160cccc061111111160cccccccc0611111111111111111111
111111111111111160cccccccc06611160cccc0660cccc0660cccccccc06611160cccccccc06611160cccc061111111160cccccccc0611111111111111111111
111111111111111160cccccccc00061160cccc0660cccc0660cccccccc00061160cccccccc00061160cccc061111111160ccccccc06111111111111111111111
111111111111111160cccc0000ccc06160cccc0660cccc0660cccc0000ccc06160cccc0000ccc06160cccc061111111160cccc00061111111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc061111111160cccc06611111111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc0660cccc066666611160cccc06666661111111111111111111
111111111111111160cccc0000cccc06160ccc0000cccc0660cccc0000cccc0660cccc0000cccc0660cccc000000061160cccc00000006111111111111111111
111111111111111160cccccccccccc06116000cccccccc0660cccccccccccc0660cccccccccccc0660ccccccccccc06160ccccccccccc0611111111111111111
111111111111111160cccccccccccc06111660cccccccc0660cccccccccccc0660cccccccccccc0660cccccccccccc0660cccccccccccc061111111111111111
111111111111111160cccccccccccc06111160cccccccc0660cccccccccccc0660cccccccccccc0660cccccccccccc0660cccccccccccc061111111111111111
1111111111111111160cccccccccc0611111160cccccc061160cccccccccc061160cccccccccc061160cccccccccc061160cccccccccc0611111111111111111
11111111111111111160000000000611111111600000061111600000000006111160000000000611116000000000061111600000000006111111111111111111
11111111111111111116666666666111111111166666611111166666666661111116666666666111111666666666611111166666666661111111111111111111
11111111111111111116666666666111111666666666611111166666666661111116666666666111111661111111111111166666666661111111111111111111
11111111111111111160000000000611116000000000061111600000000006111160000000000611116006111111111111600000000006111111111111111111
1111111111111111160cccccccccc061160cccccccccc061160cccccccccc061160cccccccccc061160cc06111111111160cccccccccc0611111111111111111
111111111111111160c7cccccccccc0660c7cccccccccc0660c7cccccccccc0660c7cccccccccc0660c7cc061111111160c7cccccccccc061111111111111111
111111111111111160cc7ccccccccc0660cc7ccccccccc0660cc7ccccccccc0660cc7ccccccccc0660cc7c061111111160cc7ccccccccc061111111111111111
111111111111111160cccccccccccc0660cccccccccccc06160cccccccccc061160cccccccccc06160cccc061111111160ccccccccccc0611111111111111111
111111111111111160cccc0000cccc0660cccc0000cccc06116000cccc000611116000cccc00061160cccc061111111160cccc00000006111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc06111660cccc066111111660cccc06611160cccc061111111160cccc06666661111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc06111160cccc061111111160cccc06111160cccc061111111160cccc06611111111111111111111111
111111111111111160cccc0000ccc06160cccc0000cccc06111160cccc061111111160cccc06111160cccc061155111160cccc00061111111111111111111111
111111111111111160cccccccc00061160cccccccccccc06111160cccc061111111160cccc06111160cccc061572511160ccccccc06111111111111111111111
111111111111111160cccccccc06611160cccccccccccc06111160cccc061111111160cccc06111160cccc061522511160cccccccc0611111111111111111111
111111111111111160cccccccc06611160cccccccccccc06111160cccc061111111160cccc06111160cccc061155111160cccccccc0611111111111111111111
111111111111111160cccccccc00061160cccccccccccc06111160cccc061111111160cccc06111160cccc061111111160ccccccc06111111111111111111111
111111111111111160cccc0000ccc06160cccc0000cccc06111160cccc061111111160cccc06111160cccc061111111160cccc00061111111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc06111160cccc061111111160cccc06111160cccc061111111160cccc06611111111111111111111111
111111111111111160cccc0660cccc0660cccc0660cccc06111160cccc061111111160cccc06111160cccc066666611160cccc06666661111111111111111111
111111111111111160cccc0000cccc0660cccc0660cccc06111160cccc061111111160cccc06111160cccc000000061160cccc00000006111111111111111111
111111111111111160cccccccccccc0660cccc0660cccc06111160cccc065111111160cccc06111160ccccccccccc06160ccccccccccc0611111111111111111
111111111111111160cccccccccccc0660cccc0660cccc06111160cccc065111111160cccc06111160cccccccccccc0660cccccccccccc061111111111111111
111111111111111160cccccccccccc0660cccc0660cccc06111160cccc061111111160cccc06111160cccccccccccc0660cccccccccccc061111111111111111
1111111111111111160cccccccccc061160cc061160cc0611111160cc06111111111160cc0611111160cccccccccc061160cccccccccc0611111111111111111
11111111111111111160000000000611116006111160061111111160061111111111116006111111116000000000061111600000000006111111111111111111
11111111111111111116666666666111111661111116611111111116611111111111111661111111111666666666611111166666666661111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111155111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111157c511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111115cc511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111155111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111166666666611111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111600000000066111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111660ccccccccc06611111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111600c77cccccccc0061111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111600cc777cccccccc006111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111660ccc7777cccccccc06111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111160ccccc777ccccccccc0611111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111160cccccc777cccccccccc061111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111160ccccc5e7e5c55cccccc061111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111160ccccc5eeee5ee5ccccc061111111111
1111111111111111111111111155111111111111111111111111111111111111111111111111111111111111111111160ccccc5eeeeeeee5cccc061111111111
111111111111111111111111157c511111111111111111111111111111111111111111111111111111111111111111160ccccc5eeeeeee85cccc061111111111
11111111111111111111111115cc511111111111111111111111111111111111111155111111111111111111111111160cccccc5eeeee85ccccc061111111111
111111111111111111111116666511111111111111111111111111111111111111157c511111111111111111111111160cccccc5ee88855ccccc061111111111
11111111111111111111116000061111111111111111111111111111111111111115cc511111111111111111111111160ccccccc58855ccccccc061111111111
1111111111111111111116022220611111111111111111111111111111111111111155111111111111111111111111160ccccccc555ccccccccc061111111111
11111111111111111111602722220611111111111111111111111111bbb1b111bbb1b1b111111111111111111111111160ccccccccccccccccc0611111111111
11111111111111111111602272220611111111111111111111111111b1b1b111b1b1b1b1111111111111111111111111160ccccccccccccccc06611111111111
11111111111111111111602222220611111111111111111111111111bbb1b111bbb1bbb11111111111111111111111111600ccccccccccccc006111111111111
11111111111111111111602222220611111111111111111111111111b111b111b1b111b111111111111111111111111111600ccccccccccc0061111111111111
11111111111111111111160222206111111111111111111111111111b111bbb1b1b1bbb1111111111111111111111111111660ccccccccc06611111111111111
11111111111111111111116000061111111111111111111111111111111111111111111111111111111111111111111111116600000000061111111111111111
11111111111111111111111666611111111111111111111111111111111111111111111111111111111111111111111111111166666666611111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111ddd11dd1d1d1ddd1ddd1d1d1ddd1ddd1dd11ddd11dd1111111111111111111111111111111111111111111
111111111111111111111111111111111111111111d1d1d111d1d11d11d111d1d1ddd1d111d1d11d11d111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111ddd1d111ddd11d11dd11d1d1d1d1dd11d1d11d11ddd1111111111111111111111111111111111111111111
111111111111111111111111111111111111111111d1d1d111d1d11d11d111ddd1d1d1d111d1d11d157cd1111111111111111111111111111111111111111111
111111111111111111111111111111111111111111d1d11dd1d1d1ddd1ddd11d11d1d1ddd1d1d11d15dd51111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111115511111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111dd1ddd1ddd1dd11ddd1ddd11dd111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111d111d1d1d111d1d11d111d11d11111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111d111dd11dd11d1d11d111d11ddd111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111d111d1d1d111d1d11d111d1111d111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111551111111111111dd1d1d1ddd1ddd1ddd11d11dd1111111111111111111111111111111155111111111111111111
1111111111111111111111111111111111157c51111111111111111111111111111111111111111111111111111111111111111111157c511111111111111111
111111111111111111111111111111111115cc5111111111111111111111111111111111111111111111111111111111111111111115cc511111111111111111
11111111111111111111111111111111111155111111111111111111111111111111111111111111111111111111111111111111111155111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111116161111116611111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111116161161161111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111611666161111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111116161161161111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111116161111116611111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111551111111111111111111111111111111111111111111111111111111111111111111111551111
111111111111111111111111111111111111111111111111157c51111111111111111111111111111111111111111111111111111111111111111111157c5111
11111111111111111111111111111111111111111111111115cc5111111111111111111111111111111111111111111111111111111111111111111115cc5111
11111111111111111111111111111111111111111111111111551111111111111111111111111111111111111111111111111111111111111111111111551111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000003000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000003000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000002000000000000000000000000000000000003000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000200000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000200000000000000000200000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000010111213101110111200100c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000404142424041404142004344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004748494847484748470c470c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000101110110d0e0d0e1200100c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000404145460f2f0f2f42004344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000047484a4a1f3f1f3f470c470c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001c1d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000002c2d2e00000024250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000003c3d3e00000034350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000a6000f601156011c6012c6013160131601236011b6010d6010d6010c6010b6010a601096010860107601096010b6010160106601076010f601186011c60125601256011c60116601126010d60109601
00010000117101b7301b7501175000700187001370013700187041870500700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100001e730217301e7301c5001c5001c5001c5001c5001c5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00010000270502e050370503d0503d0502b050265500000000000000000c3000c405000000000000000000000c3000000000000000000c30000000000000740500000000000c2050000000000000000c30000000
00010000267502b750307550000000000000000000000000246050000000000000000c30018605000000000018000180002430018000180001800024300180001800018000000000000000000000000000000000
0001000029720297302e7302e7302e7302b7200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000180001a00015000160000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c0000c000000000000000000000000000000000
0001000018000160001300011000295052650529505265052d505295052950526505225051f5051d505215052e5052b50528505245052d5052d5052850528505265052e5052b5052850524505215051d50521505
0001000020704200051c7041c0051970419505157043950520704200051c7041c0051950219005147041500121704210051c7041c0061970419005237041700521704395051c7041c00519704195051770717005
000100000c003090052070409005246051970315505090050c003090051970309505207042460509005155050c003060052070406005246051670306005125050c00306005167030650520704246050600515505
000100000c003021051e7040200524605197050e7050c00302105020051e7041e7050250524605020050e50501105010051e7040c00324605167030b0050d0050c00301105197040b50520704246050100515505
0001000020704200051c7041c00525702287021570439505207042a7022c7012c7022c70219005147042a70228702287051c7041e7021e7021e705237041700521704395051c7041c00519704195051770617005
0001000020704200051c7041c00525702287021570439505207042a7022c7012c7022c70219005147042f7022d7022d7052d704217022170221705237041700521704395051c7041c00519704195051770617005
0001000006005061050d005061050d507061050d005061050d005060050610501105065070d10504005041050b005041050b507041050b005041050b0050b105040050b105045060b1050b005041050b0050b105
000100001e4021e4021f4061e4061c4021c4021e4021e4021e4021e4021f4061e4061c4021c4021c4021c4021c4021c4021c4021c4021c4021c4021c4021c4021c4021c4021c4021c40510105101051010510105
000100001e4001e4021e4021e4050650500505065051a0041a005065051a0050650500505065051900419005045051700404505005050450500505045051e0041e005045051e0040450504505005050450504505
000100001e4021e4061f4061e4061c4021c4021a4051c4051e4051f40521405234052640528405254022540219402194022540225402264062540623402234022140221402234072340625400234002140520405
00010000190041900506505135000650500505065051a0041a005065051a0050650506404065051900419005045051700404505005050450500505045051e0041e005045051e0040450504505005050450504505
010e000005455054553f52511435111250f4350c43511125034550345511125182551b255182551d2551112501455014552025511125111252025511125202550345520255224552325522455202461d4551b255
010e00000c0530c4451112518455306251425511255054450c0530a4353f52513435306251343518435054450c053111251b4353f525306251b4353f5251b4350c0331b4451d2451e445306251d2451844516245
010e00000145520255224552325522445202551d45503455034050345503455182551b455182551d455111250045520255224552325522455202461d4551b255014550145511125182551b455182551d45511125
010e00000c0531b4451d2451e445306251d245184450c05317200131253f52513435306251343518435014450c0431b4451d2451e445306251d245184451624511125111253f5251343530625134351843500455
010e0000004550045520455111251d125204551d1252912501455014552c455111251d1252c4551d12529125034552c2552e4552f2552e4552c2552945503455044552c2552e4552f2552e4552c246294551b221
010e00000c0530c0531b4551b225306251b4551b2250f4250c0530c05327455272253062527455272251b4250c0531b4451d2451e445306251d245184450c0530c0531b4451d2451e445306251d2451844500455
000100000c0030440504205134053f6050440513205044050c0031340513205044053f6050440513205134050c0030440504205134053f6050440513205044050c0031340513205044053f605044051320513405
0001000028505234052d2052b5052a4052b2052f50532205395003720536500374053b2003950537400342053650034205325052f2002d5052b2002a4052b500284052620623500214051f20023505284002a205
000100002b5052a4052820523505214051f2051e5051c4052b205235052a405232052d5052b4052a2052b505284052a205285052640523205215051f4051c2051a505174051e2051a5051c4051e2051f50523205
000100000c0030040500205104053f6050040510205004050c0030040500205104053f6050040510205104050c0030040500205104053f6050040510205004050c0031040510205004053f605004051020500405
000100000c0030240502205124053f6050240512205024050c0031240512205024053f6050240502205124050c0030240502205124053f6050240512205024050c0030240512205024053f605124050220512405
000100002b5052a40528205235052b5052a40528505235052b5052a00528505235052b0052a00528705237052b0052a00528705237051f7051e7051c705177051f7051e7051c705177051370512705107050b705
000100000c0030c205004003a304004053c3053c3040c0033c6050c0030040000400002053e5053e5050c1030c0030f204034051b303034053700437502370053c6053e5050330003400032051b3030c0031b303
000100000c00312205064003a304064053c3053c3040c0033c6050c0030640006400062053e5053e5050c1030c00311204054051b303054053a0042e5023a0053c6053e50503305054051320605406033051b303
000100002200524205244002430422405243052430422305223052400522400242042220524405245052420522305222042440524306224052400424502220052450524504223052440522207244062430522305
00010000224002b4002e40030400304003040033400304003040030202294002b2002e400302002b400272002a4002a4022a40227400274002740025401274012740027400274002720027402272022740227202
000100002a4002a4022a402274002740027402272022740527400254002a2002e4002b2002a406252002a4002740027402274022440024202244022240124401244002440024400244002420024402182010c401
011100000c3430035500345003353c6150a3300a4320a3320c3430335503345033353c6151333013432133320c3430735507345073353c6151633016432163320c3430335503345033353c6151b3301b4321b332
01110000162251b425222253751227425375122b5112e2251b4352b2402944027240224471f440244422443224422244253a512222253a523274252e2253a425162351b4352e4302e23222431222302243222232
011100000c3430535505345053353c6150f3301f4260f3320c3430335503345033353c6151332616325133320c3430735507345073353c6151633026426163320c3430335503345033353c6150f3261b3150f322
011100001d22522425272253f51227425375122b5112e225322403323133222304403043030422375112e44237442372322c2412c2322c2222c4202c4153a425162351b4352b4402b4322b220224402243222222
011100001f2401f4301f2201f21527425375122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
01110000182251f511242233c5122b425335122b5112e225162251b5112e2253a5122b425375122b5112e225162251b425225133021033410375223341027221162251b425222253751227425373112b3112e325
011100000f22522425272253f51227425375122b5112e2252724027232272222444024430244222b511224422b4422b23220241202322023220420204153a425162351b4351f4401f4321f2201d4401d4321d222
000100000c8010c8010c8000c8000c8000c8000c8000c8000c8000c8000c8000c8000c8000c8000c8000c80018801188001880018800188001880018800188002480124800248002480024800248002480024800
00010000269042690026900185051870007505075040750507504000002490424900249001d5041d7000c5050c5042950500000000002b505000001d5041d5050a5040a5050a5040a5001a7041a7050a0050a004
000100000070400705007040070500704007050070400705007040070500000057040570505704057050570405705057040570503704037050370403705037040370503704037050370403705037040370503704
000100000a0041f704219042190224a0424a0224a05265051a5041a5050000026904269021ba041ba001ba050c5040c5050c5040c505000001f9041f9001f905225051f5041f50522a0022a0222a052b7042b705
0001000005b0008b0009b000ab0009b0008b0006b0002b0001b0006b0006b0003b0002b0003b0005b0007b0008b0009b000ab000ab000ab0009b0008b0007b0005b0003b0002b0002b0002b0002b0004b0007b00
0001000000c060cc060cc0600c0600c0600c060cc060cc060cc0600c0600c060cc060cc060cc0600c0600c060cc0600c0600c0600c060cc060cc060cc0600c060cc0600c060cc060cc0600c060cc060cc0605c06
000100000cb000fb0010b0011b0010b000fb000db0009b0008b000db000db000ab0009b000ab000cb000eb000fb0010b0011b0011b0011b0010b000fb000eb000cb000ab0015b0015b0015b0015b000bb000eb00
0001000000000000000000000000000000000000000000001370413700137001370015704157001570015702137041870418700187001870018700187001870018705187021a7041c7011c7001c7001c7001c700
000100001c7001f7041f7001f7001f7001f700157041570015700157001570015700157001570215705000001c7041c7001c7001c7001c7001f7041f7001f7001f7001f702157041570015700157001570015700
000100001570015705000001f7041c7041c7001c7001c7001c7001c70215704137011370013700137001370013700137021870418700187001870018700187001870018700187001870218705187001870018705
000100000dd050dd050dd050dd051070510705107051070500c0517d0517d0517d0517d0517d0510705107050dd050dd050dd050dd051070510705107051070500c0417d0517d0517d0517d0517d050dd050dd05
000100001070519d0519d0519d0519d051000510005100051000517d050f7050f7050f7050f70510705107051070519d0519d0519d0519d050b0050b0050b7050b0050b7050b70517d0517d050f7050f7050f705
0001000012d0512d0512d0512d051570515705157051570500c0510d0510d0510d0510d0510d05157051570512d0512d0512d0512d05157051570500c04157051570519d0519d0519d0519d0519d050dd050dd05
00010000107051ed051ed051ed051ed051500515005150051500517d05147051470514705147051570515705157051ed051ed051ed051ed0515005150051570515005157051570519d0519d050f7050f7050f705
0001000019d0519d050dd0501d051400014000147021470223d0523d050bd050bd051500015000157021570219d0519d050dd0501d051700019000197021970223d0523d050bd050bd051c0001e0001e7021e702
000100001ed051ed0512d0506d052100021000217022170228d0528d0528d0520000200021e0001e7021e7021ed051ed0512d0506d052100021000257022570228d0528d0528d0528d051c0001e0001e7021e702
0001000024e0524e0521f051ff051ff051de0524f0524f0518e051de051fe051d70018e051de051fe051d7021ff0521f0524f052970029e052be052ee0524e0524e0524e0521f051ff051ff051de052470224f05
0001000024e0524e05219051ff052190524e0524e0524f0526f0526f051fe051d70232f0532f052be05297022bf052bf052df053570235e0537e053ae0530e0530e0530e052df052bf052bf0529e053070230f05
000100002de052de052af0528f0528f0526e052df052df0521e0526e0528e052670221e0526e0528e052670228f052af052df053270232e0534e0537e052de052de052de052af0528f0528f0526e052d7022df05
000100000a0050a0050a0050a0050a0050a0050a0050a0050a0050a0050a005050050a0050a0050a0050a0050a005050050a0050a0050a0050a0050a005050050a0050a005050050a0050a005050050a0050a005
010100000500505005050050500505005050050500505005050050500505005000050500505005050050500505005000050500505005050050500505005000050500505005000050500505005000050500505005
010100000700507005070050700507005070050700507005070050700507005020050700507005070050700502005020050200502005020050200502005090050200502005090050200502005090050200502005
__music__
00 48494344
00 484a4344
04 4b494344
00 4c4a4344
00 4b494344
00 4c4a4344
01 12134344
00 12134344
00 12134344
00 12134344
00 14154344
00 14154344
02 16174344
00 58424344
00 5b424344
00 5c424344
00 59424344
00 585a4344
00 5b5a4344
00 5c594344
00 585d4344
00 5e424344
00 5f424344
00 5e604344
00 5f604344
00 5e604344
00 5f604344
00 5e614344
00 5f624344
00 5e614344
00 5f624344
00 23424344
00 23424344
01 23244344
00 23244344
00 25294344
00 25264344
00 23274344
02 23284344
00 6a6c6c6d
00 6e6f7071
00 6e6f7072
00 6e6f7073
00 74754344
00 74754344
00 76774344
00 74784344
00 74784344
00 76794344
00 4d517f44
00 4d517f44
00 4d4e7f44
00 4d4e7f44
00 4d507f44
00 4d507f44
00 4d4f7f44
00 7d7a4344
00 7e7a4344
00 7d7b4344
00 7e7a4344
00 7f7c5344
00 7f7c5344
00 7e7f5344
00 7e7f5344
