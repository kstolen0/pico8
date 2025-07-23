pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- main

function _init()
 home:init()
end

function _update()
 if lvl<1 then
  home:update()
 else
	 if not lcm then
	  dog:update()
	  for i in all(items) do
		  i:update(dog)
		 end
		 for h in all(humans) do
		  h:update()
		 end
	 end
	 if wcm or
	 lcm then
	  if btnp(❎) then
	   lvl=0
	   home:init()
		 end
		end
	end
end

function _draw()
 cls()
 if lvl<1 then 
  map(offset.x,offset.y)
  home:draw()
 else
  if show_win_message then
		 print("you win!",50,60)
		 print("press v to return",
		  32,
		  70)
		 return
	 end
	 if lcm then
	  print("bad dog!!",50,60)
	  print("press v to return",
	   32,
	   70)
	  return
	 end
  map(offset.x,offset.y)
  dog:draw()
	 for i in all(items) do
	  i:draw()
	 end
	 for h in all(humans) do
	  h:draw()
	 end
 end
end
-->8
-- dog

-- the different positions
-- the dog can be and their 
-- properties

dog_state = {
  -- stand
 {
  n_state = 2, -- next state is sitting
  sprite = 0, -- stand sprite starts here
  max_frame = 2, -- 2 animation frames for this sprite
  speed = 1, -- how quickly dog can move from standing
  s_offset = 0, -- moving animation offset
  hs=9
 },
  -- sit
 {
  n_state = 3, -- next state is lying down
  sprite = 16, -- sit sprite starts here
  max_frame = 2,
  speed = 0, -- sitting dogs cannot move in this world
  s_offset = 0,
  hs=5
 },
  -- lie
 {
  n_state = 1, -- next state back to standing
  sprite = 32, -- lying sprite starts here
  max_frame = 2,
  speed = 0.3, -- dog can crawl
  s_offset = 2,
  hs=4
 },
}

dog_facing = {
	left = {
	 flip = true,
	 sprite = 0,
 },
 right = {
  flip = false,
  sprite = 0,
 },
 up = {
  flip = false,
  sprite = 4
 },
 down = {
  flip = false,
  sprite = 8
 }
}

function init_dog(x,y)
	return {
	 x = 8*x,
	 y = 8*y,
	 state = dog_state[1],
	 frame = 0,
	 f_timer = 0.2,
	 facing = dog_facing.right,
	 has_treat = false,
	 update=function(self)
	  -- animate
		 self.frame+=self.f_timer
		 if self.frame >= 
		 self.state.max_frame then
		  self.frame = 0
		 end
		 
		 -- win condition
		 if wcm and 
		 not show_win_message then
		  self.y+=self.state.speed
		  
		  if cworld(self) then
		   show_win_message=true
		  end
		  return
		 end
		 
		 -- sit/lie
		 if btnp(❎) then
			 self.state=dog_state[
			  self.state.n_state
			 ]
		 end
		 
			-- moving
		 self.state.s_offset = 0
		 local px=self.x
		 local py=self.y
		 if btn(➡️) then
		  printh("dog move right")
		  self.x+=self.state.speed
		  self.facing=dog_facing.right
		  self.state.s_offset = 1
		 elseif btn(⬅️) then
		  printh("dog move left")
		  self.x-=self.state.speed
		  self.facing=dog_facing.left
		  self.state.s_offset = 1
		 elseif btn(⬆️) then
		 	printh("dog move up")
		  self.y-=self.state.speed
		  self.facing=dog_facing.up
		  self.state.s_offset = 1
		 elseif btn(⬇️) then
		  printh("dog move down")
		  self.y+=self.state.speed
		  self.facing=dog_facing.down
		  self.state.s_offset = 1
		 end
		 if cflag(self,flags.wallpaper) or
		  cworld(self) then
		  self.x=px
		  self.y=py
		 end
		 
		 -- check win condition
		 if cflag(self,flags.fdoor) and 
	  self.has_treat then
		  if not wcm then
		   wcm=true
		   music(-1)
		   sfx(5)
		  end
		 end
	 end,
	 
	 draw=function(self)
	   spr(
			  self.state.sprite+ -- stand/sit/lie
			   self.frame+ -- sprite animation offset
			   self.facing.sprite+ -- left/up/down offset
			   (self.state.s_offset* -- moving offset
			    self.state.max_frame),
			  self.x,
			  self.y,
			  1,
			  1,
			  self.facing.flip -- facing left or right
			 )
	 end
	}
end

dog=init_dog(0,0)


-->8
-- collision

flags={
	wall=0,
	treat=1,
	human=2,
	fdoor=7
}

function czone(o,x,y,w,h)
 local ox=o.x/8
 local oy=o.y/8
 return ox >= x and
  ox < x+w and
  oy >= y and
  oy < y+h
end

function cflag(o,flag)
 
 local x1=o.x/8+offset.x
 local y1=o.y/8+offset.y
 local x2=(o.x+7)/8+offset.x
 local y2=(o.y+7)/8+offset.y
 
 local a=fget(mget(x1,y1),flag)
 local b=fget(mget(x1,y2),flag)
 local c=fget(mget(x2,y1),flag)
 local d=fget(mget(x2,y2),flag)
 
 return a or b or c or d
end

function cworld(o)
 
 return (o.x < 0) or 
  (o.y < 0) or
  (o.x > 120) or
  (o.y > 120)
end

function rcol(a,b)
 
 local x=sqr(b.x-a.x)
 local y=sqr(b.y-a.y)
 local dist=sqrt(x+y)
 
  return dist<7
end

function rcol2(ax,ay,bx,by,d)

 local x=sqr(bx-ax)
 local y=sqr(by-ay)
 local dist=sqrt(x+y)
 
 printh("distance is "..dist)
 return dist<d
end

function sqr(x)
 return x*x
end
-->8
-- treats

treats={
 steak=44,
 butter=60
}

function treat_factory(x,y,t)

	return {
	 x=x,
	 y=y,
	 active=0,
	 sprite=t,
	 update=function(self,d) 
	  if self.active==1 then
		  self.x=dog.x
    self.y=dog.y
		  return
		 end
		 if rcol(self,d) then
		  self.active=1
    d.has_treat=true
    sfx(4)
		 end
	 end,
	 draw=function(self)
	  spr(self.sprite+self.active,
	   self.x,
	   self.y,
	   1,
	   1)
	 end
	}
end





-->8
-- human

hmnflg={
	bob=128,
	linda=144
}

-- human facing
hf = {
 left={
  so=0,
  flip=true,
  x=-1,
  y=0,
  name="left",
  see=function(self,d)
   
   x=self.x/8
   y=self.y/8
   while x > -1 do
    printh(self.sprite.." checking "..x)
    cw=fget(mget(x+offset.x,y+offset.y),
     flags.wall)
    if cw then
     printh(self.sprite.."see wall")
     return false
    end
    cd=rcol2(x*8,y*8,d.x,d.y,d.state.hs)
    if cd then
     printh(self.sprite.."see dog")
     return true
    end
    x=x-1
   end
   return false
  end
  },
 right={
  so=0,
  flip=false,
  x=1,
  y=0,
  name="right",
  see=function(self,d)
   x=self.x/8
   y=self.y/8
   while x < 16 do
    printh(self.sprite.." checking "..x)
    cw=fget(mget(x+offset.x,y+offset.y),
     flags.wall)
    if cw then
     printh(self.sprite.."see wall")
     return false
    end
    cd=rcol2(x*8,y*8,d.x,d.y,d.state.hs)
    if cd then
     printh(self.sprite.."see dog")
     return true
    end
    x=x+1
   end
   return false
  end
  },
 down={
  so=1,
  flip=false,
  x=0,
  y=1,
  name="down",
  see=function(self,d)
   x=self.x/8
   y=self.y/8
   while y < 16 do
    printh(self.sprite.." checking "..x)
    cw=fget(mget(x+offset.x,y+offset.y),
     flags.wall)
    if cw then
     printh(self.sprite.."see wall")
     return false
    end
    cd=rcol2(x*8,y*8,d.x,d.y,d.state.hs)
    if cd then
     printh(self.sprite.."see dog")
     return true
    end
    y=y+1
   end
   return false
  end
  },
 up={
  so=2,
  flip=false,
  x=0,
  y=-1,
  name="up",
  see=function(self,d)
   x=self.x/8
   y=self.y/8
   while y > -1 do
    printh(self.sprite.." checking "..x)
    cw=fget(mget(x+offset.x,y+offset.y),
     flags.wall)
    if cw then
     printh(self.sprite.."see wall")
     return false
    end
    cd=rcol2(x*8,y*8,d.x,d.y,d.state.hs)
    if cd then
     printh(self.sprite.."see dog")
     return true
    end
    y=y-1
   end
   return false
  end
  }
 } 

-- human state
hs = {
 idle=function(self)
  if self.facing.see(self,dog) then
   music(1)
   self.update=hs.chase
  end
  
	 timer=self.timer
	 timer.current+=0.3
	 if timer.current>=
  timer.max then
	  timer.current=0
	  self:turn()
	  end
 end,
 
 chase = function(self)
  local px=self.x
  local py=self.y
  self.x+=self.facing.x
  self.y+=self.facing.y
  if cflag(self,flags.wall) or
   cflag(self,flags.human) or
   cflag(self,flags.fdoor) or 
   cworld(self) or 
  rnd(1)<0.01 then
   self.x=px
   self.y=py
   
   self:turn(face_rnd())
  end
  if rcol(self,dog) then
   if not lcm then
    lcm=true
    music(-1)
    sfx(6)
   end
  end
 end
}

function human_factory(x,y,sprt,fc)
 return {
  x=x,
  y=y,
  sprite=sprt,
  facing=fc,
  see=fc.see,
  timer={
   current=0,
   max=30
   },
  draw=function(self)
	  spr(self.sprite+
	   self.facing.so,
	  self.x,
	  self.y,
	  1,
	  1,
	  self.facing.flip)
  end,
  update=hs.idle,
  turn=function(self,f)
	  if not f then
		  f=self.facing.name
			 if f=="left" then
			  self.facing=hf.up
			 elseif f=="up" then
			  self.facing=hf.right
			 elseif f=="right" then
			  self.facing=hf.down
			 else
			  self.facing=hf.left
			 end
		 else 
		  self.facing = f
		  self.see=self.facing.see
		 end
  end
 }
end

function face_rnd()
 local x = rnd({1,2,3,4})
 if x==1 then
  return hf.left
 elseif x==2 then
  return hf.up
 elseif x==3 then
  return hf.right
 elseif x==4 then
  return hf.down
 end
end
-->8
-- levels
lvl=0
items={}
humans={}

home={
 init=function(self)
  show_win_message=false
		lcm=false
		wcm=false
		music(3,0,14)
  dog=init_dog(1,14)
  offset={
   x=0,
   y=16
  }
  humans={}
  items={}
 end,
 update=function(self)
  dog:update()
  check_lvls()
 end,
 draw=function(self)
  dog:draw()
  print((dog.x/8).." "..dog.y/8)
 end,
}

function check_lvls()
 if czone(dog,5,14,1,1) then
  lvl=1
 elseif czone(dog,3,5,1,2) then
  lvl=2
 elseif czone(dog,11,4,2,2) then
  lvl=3
 elseif czone(dog,11,9,2,2) then
  lvl=4
 else
  lvl=0
 end
 if lvl > 0 then
  lvls[lvl]:init()
 end
end

lvls={
 -- level 1
 {
  init=function(self)
  	show_win_message=false
			lcm=false
			wcm=false
			music(2)
			offset.x=0
			offset.y=0
			dog=init_dog(8,15)
				 
			items={
				treat_factory(
				 8*5,
				 8*2,
				 treats.steak)
			}
			
			humans={
				human_factory(
					 8*2,
					 8*1,
					 hmnflg.bob,
					 hf.left),
				human_factory(
					 8*5,
					 8*6,
					 hmnflg.linda,
					 hf.right)
			}
  end
 },
 -- level 2
 {
  init=function(self)
   show_win_message=false
			lcm=false
			wcm=false
			music(0)
			offset.x=16
			offset.y=0
			dog=init_dog(0,5)
			items={
			 treat_factory(
			 8*12,
			 8*14,
			 treats.butter)
		 }
		 humans={
		  human_factory(
			 8*11,
			 8*5,
			 hmnflg.bob,
			 hf.up),
			 human_factory(
			 8*4,
			 8*2,
			 hmnflg.bob,
			 hf.down)
		 }
  end
 },
 
 -- level 3
 {
  init=function(self)
   show_win_message=false
			lcm=false
			wcm=false
			music(0)
			offset.x=32
			offset.y=0
			dog=init_dog(15,2)
			
  end
 }
}

__gfx__
00000000000000000000000000000000000110000001100000011000001100000005600000556000055600000055600000000000000000000000000000000000
00006600000066000000660000000000000660000006600000066000006600000006600000066000006600000006600000000000000000000000000000000000
0000646100006461000064610000660000566500005665000056650005665000005f6f00005f690005f69000005f690000000000000000000000000000000000
56f6666656f6666656f666660000646100f6660000f6660000f666000f66600000566f0000666f000666f00000666f0000000000000000000000000000000000
56f6ff0056f6ff0056f6ff0056f666660006f0000006f0000006f000006f00000066660000666600066660000066660000000000000000000000000000000000
06666600056666000666666056f6ff000006f0000006f0000006f000006f00000047740000477400047740000047740000000000000000000000000000000000
06005600060056000650506006666650000660000006600000066000006600000061160000611600061160000061160000000000000000000000000000000000
0600560006005600060050000500060000065000000560000006500000560000000e800000088000008800000008800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000
00006461000064610000646100006461000110000001100000011000000110000055500000555000005550000055500000000000000000000000000000000000
0000666600006666000066660000666600566500005665000056650000566500000f6000050f6000050f6000050f600000000000000000000000000000000000
000f6600000f6600000f6600000f660000f6660000f6660000f6660000f6660000566f0000566f0000566f0000566f0000000000000000000000000000000000
006665000066650000666500006665000006f0000006f0000006f0000006f0000066660000666f0000666f0000666f0000000000000000000000000000000000
0f6f65000f6f65000f6f65000f6f65000006f5000006f0000006f5000006f5000047740000477400004774000047740000000000000000000000000000000000
5f6665005f6565005f6665005f656500000550000005550000055000000550000061160000611600006116000061160000000000000000000000000000000000
55556500555665005555650055566500000000000000000000000000000000000005500000055000000550000005500000000000000000000000000000000000
00000000000000000000000000000000000110000001100000011000000110000565560005655600006660000006660000000000000000000000000000000000
00000000000000000000000000000000000660000006600000066000000660000066660005666600005666000066650000777700000000000000000000000000
0000000000000000000000000000000000566500005665000056650000566500000f6000000f6000000f6500005f600007886870000000000000000000000000
0000660000006600000000000000660000f6660000f6660000f6660000f66600005f6f00005f6f00005f6f00005f6f0007867880000000000000000000000000
000064610000646100006600000064610006f0000006f0000056f0000006f5000066660000666600006666000066660007888840000002800000000000000000
06ff666606ff666606ff646106ff66660056f5000056f5000056f5000056f5000056650000566500006666000056650008884000000028870000000000000000
ff665600ff565600ff665666ff665600006666500066660000666600006666000065560000655600005555000055550000840000000288870000000000000000
65565500656655005566555065565500000655000006555000066600006660000001100000011000000110000001100000840000000777700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999a7a000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999aa7000009900000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999a099999a00000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999999900999a000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000009949449494444444400000000555555550000000000000000000000009292929292929292929292921111151111111511111115116666666755555555
00000949949449494999999400000000444444440000000000000000000000002222222222222222222222291111151111111511111115117777777644444544
00094449949499494944449400000000249324130000000000000000000000009229292929292929292929221177777777777777777777117777777644444544
09444949949994494944449400000000249324130000000000000000000000002292992292929292229222295577777777777777777777117777777655555555
94499949949444904944449400000000555555550000000000000000000000009229292222222222229229221177777777777777777777117777777644544444
94994949944490004999999400000000942943940000000000000000000000002299992222222222229992291177777777777777777777557777777655555555
94944949949000004444444500000000942943940000000000000000000000009222229222222222292229221177777777777777777777117777777644444445
94944949900000004444445500000000555555550000000000000000000000002292222222222222222222291177777117777771177777117777777644444445
666666666cccccc64567775400000000000000000000000000000000000000009229222222292222222229221177777117777771177777113333333354444544
6cccccc66cccccc64666667400000000000000000000000000000000000000002292222222922222222292291177777777777777777777113b33333344454444
6ccc77c6666666664666667400000000000000000000000000000000000000009229222229229222222229225577777777777777777777113333333345444454
6cccccc66cccccc64666667400000000000000000000000000000000000000002292222222922922222292291177777777777777777777113333b33344445444
6cccccc66cccccc64666667400000000000000000000000000000000000000009229222222292292222229221177777777777777777777113333333344544445
666666666cccccc64666667400000000000000000000000000000000000000002292222222222922222292291177777777777777777777553333333354444544
6cccccc66cccccc6466666640000000000000000000000000000000000000000922922222222922222222922117777777777777777777711333333b344454444
6cccc7c6666666664555555400000000000000000000000000000000000000002292222222292222222292291177777117777771177777113333333345444454
000000000000000000000000000000000000000000000000000000000000000092222222222222222222292211777771177777711777771155555d55cccccccc
000000000000000000000000000000000000000000000000000000000000000022922292222222222922222911777777777777777777771155555555cccccccc
00000000000000000000000000000000000000000000000000000000000000009229992222222222229999225577777777777777777777115d555555cccddccc
000000000000000000000000000000000000000000000000000000000000000022922922222222222292922911777777777777777777771155555555ccdccdcc
000000000000000000000000000000000000000000000000000000000000000092222922292929292299292211777777777777777777771155d5555dccdccdcc
000000000000000000000000000000000000000000000000000000000000000022929292929292929292922911777777777777777777775555555d55cccddccc
000000000000000000000000000000000000000000000000000000000000000092222222222222222222222211511111115111111151111155555555cccccccc
00000000000000000000000000000000000000000000000000000000000000002929292929292929292929291151111111511111115111115d555555cccccccc
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006dd2ddd6
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6dddd6d
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6dddd6d
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd6dd6d2
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002d6dd6dd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6dddd6d
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6dddd6d
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ddd2dd6
ff44444044ffff4444ffff4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444fff4ffffff4444ff44400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444ff1fff1ff1ff4444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffff4444ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776666777766666665566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77767776777767777774477700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccdccccdcccccc44ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccdccccccccccccdccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110011111100111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111ff1ffffff11111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111ffcf1fcffcf11111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1fffffffffffffff1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1aaaa9aaaaaffaaaf111111f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a9affaa9a9aaa9a9f119a11f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaaffaaaaaa9aaaa9aaaaaa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a9aaaa9a9aaaa9a9aa9aa9aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555533333333444445449dddd999000000005335533533553535335335530000000000000000000000000000000000000000000000000000000000000000
55555555333333b345444444d999d9990000000033333333333333333b3333330000000000000000000000000000000000000000000000000000000000000000
555555553333333344444444d999d999000000003333333333333333333333350000000000000000000000000000000000000000000000000000000000000000
555555553333333344444444d999d99900000000533b333333333333333333330000000000000000000000000000000000000000000000000000000000000000
555555553333333344544444d9999ddd000000005333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
555555553333333344444454d999d99900000000333333333333333333b333350000000000000000000000000000000000000000000000000000000000000000
555555553333333344444444d999d999000000003333333333333333333333350000000000000000000000000000000000000000000000000000000000000000
555555553333333345444444d999d999000000005333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
55555555000000000000000000000000000000005333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000003333333333333333333333350000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000003333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000005333333333333b33333333330000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000003333333333333b33333333350000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000003333333333b333b3333333330000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000005333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000003333333333333333333333350000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000533333b333333333333333b30000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003b33333333333333333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333333333333333350000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033333b333333333333333b350000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333333333333333330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005335335333535533533533530000000000000000000000000000000000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6261dddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6666dddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddf66dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd6665dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddf6f65dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd5f6565dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd555665dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000008000010000000000000000000000010180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
0404040000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4b4c4c4c4c4c4c4c4c4d404b4c4c4c4d5e5e7f4f4f4f4f4f4f7f4f4f4f4f4f4f4e4e4e4e4e4e4e4e4e4e7f4e4e7f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c5c5c5c5c5c6c6c6d416b6c6c5c5d5e5e7f4f4f4f4f4f4f7f4f4f4f4f4f4f4e4e4e4e4e4e4e4e4e4e7f4e4e425f5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b5c5c5c5c5c5d7f7f7f7f7f7f7f6b6d5e5e7f4f4f4f7f4f4f7f4f4f4f4f4f4f4e4e4e4e4e4e4e7f4e4e7f4e4e525f5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b6c6c6c6c6c6d7f4f4f4f4f4f4f4f4f5f5e7f4f4f4f7f4f4f7f4f4f4f4f4f4f4e4e4e4e4e4e4e7f4e4e7f4e4e7f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f7f7f7f7f7f7f4f4f4f4f4f4f4f4f5f5e7f4f4f447f4f4f4f4f4f7f444f4f7f7f7f7f7f7f7f7f4e4e7f4e4e7f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4f4f4f4f4f4f4f4f7f4f4f4f4f4f5f5e7f4f4f447f4f4f4f4f4f7f7f4f4f6e6e6e6e6e6e6e7f4e4e4e4e4e7f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4f4f4f4f4f4f4f4f7f4444444f4f5f5e7f4f4f447f7f407f4f4f4f4f4f4f6e6e6e6e6e6e6e7f4e4e4e4e4e7f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4f4f4f4f4f7f4f4f7f7f7f7f7f7f5f5e7f4f4f4f7f7f417f7f4f4f4f4f4f6e6e6e6e6e6e6e7f4e4e7f7f7f7f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f484949494a4f7f4f4f4f4f4f4f4f4f5f5e7f4f4f4f7f4b4c4d7f4f4f4f4f4f7f7f7f7f7f4e4e7f4e4e4e7f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f585959595a4f7f4f4f4f4f6f6f4f4f5f5e7f4f4f4f7f5b5c5d7f7f7f7f4f4f4e4e4e4e4e4e4e4e4e4e4e7f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f585959595a4f7f4f4f7f4f6f6f4f4f5f5f424f4f4f7f5b5c5d404f4f4f4f4f4e4e4e4e4e4e4e4e4e4e4e7f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f686969696a4f7f4f4f7f4f6f6f4f4f5f5f524f4f4f7f6b6c6d414f4f4f4f4f4e4e4e4e4e4e4e4e4e4e4e7f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f4f4f4f4f4f4f7f42507f4f4f4f4f4f7f7f7f7f4f4f7f7f7f7f7f4f4f7f7f7f4e4e7f7f7f7f7f7f7f7f7f7f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7f7f7f7f7f7f7f7f52517f7f7f7f7f7f4f4f4f484949494a7f4b4c4c4c4c4c4d6e6e6e6e6e6e6e6e6e7f4f4f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5e5e5e5e5e5e5e5e5f5f5e5e5e5e5e5e4f4f4f585959595a7f5b5c5c5c5c5c5d6e6e6e6e6e6e6e6e6e7f4f4f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5f5f5f5f5f5f5f5f5f5f5e5e5e5e5e5e4f4f4f686969696a7f6b6c6c6c6c6c6d6e6e6e6e6e6e6e6e6e7f4f4f4f4f4f4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c5c6c6c6d6c6d6c6c6c7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0d5c3c3d6c3c3c3c3d0d0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0e5c3c3c1c3c3c3c3d0d0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c2c3c3c1c3c3c3c3c0c7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c2c3c3d6c1c1c1c1d6d7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c5c1c1c1c1c3c3d6d6e7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0d5c3c3c3c1c3c3c3d0d0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0d5c3c3c3d6c3c3c3d0d0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0d6c3c3c3c1c3c3c1d6c7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0d5c3c3c3c1c3c3c1d6d7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0d5c3c3c3c1c1c1c1c1d7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0e5e7c2d5c1c3c3c3c3d7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c2c2c2d5d6c3c3c3c3d7c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011600000c0530e6150e6150e6150e6150e6150e6150e615186100e6150e6150e6150e6150e6150e6150e6150c0530e6150e6150e6150e6150e6150e6150e615186100e6150e6150e6150e6150e6150e6150e615
011000000e153001000e153001000e153001000e153001000010000000001000e100001000e10000100001000010000100001000010000100000000e100000000e10000000000000000000000000000000000000
011000001a3131a3131a313000001a313183031a313000000e100000000e100000000e100000000e100000001a3131a3131a313000001a313183031a313183030e100000000e100000000e100000000e10000000
011000000c0530e6150e6150e615186100e6150e6150e6150c0530e6150e6150e615186100e6150e6150e6150c0530e6150e6150e615186100e6150e6150e6150c0530e6150e6150e615186100e6150e6150e615
00020000000500305005050070500a0500c0500f050110501305016050180501b0501f05024050290502e0501b0001d0001b00018000180001600016000130001300013000160001600013000110000700007000
0010000003050030500305005050050500a0500c0501305013050110500f0500f05011050160501f0501d0501b0501805018050180501b0501f05024050290502e0502b050290502705027050290502e05035050
001000002b0302903027030240302703024030220301f030220301f0301d0301b0301d0301b0301803016030180301603013030110300f0300f0300f0300f0300000000000000000000000000000000000000000
191400001652016525135201352511520115250f5200f525115201152513520135251852018525135201352511520115250f5200f525115201152513520135251a5201a525165201652513520135251352013525
011000001c7201c720187201872518720187201c7201c720187201872518720187201a7201a720187201872518720187251a7201a720187201872518720187251c7201c720187201872518720187251c7201c720
01100000187201872518720187251a7201a720187201872518720187251a7201a7201872018725187201872515720157201872018725187201872515720157201872018725187201872513720137201872018725
011000001872018725137201372018720187251872018725157201572018720187251872018725157201572018720187251872018725137201372018720187251872018725007200072018720187251872018725
011000000e123001030010300103131230010300103001030e123001030010300103131230010300103001030e123001030010300103131230010300103001030e12300103001030010313123001030010300103
__music__
02 00014344
03 03024344
03 07424344
01 080b4344
00 090b4344
02 0a0b4344

