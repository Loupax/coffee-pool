pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- barista billiards

-- constants
drag=0.98
stopv=0.05
cd_frames=10
ball_r=4
pocket_r=6
aim_pow_max=4

-- globals
state=-1 -- -1=title,0=aim,1=sim,2=eval,3=recipe
input_lock=0
inv={} -- inventory per type
fouls=0
global_score=0
shots=0
par=0
mult=0
theta=0
power=0
charging=false
lvl_idx=1
ents={}
cue=nil
msg=""
msg_t=0
gameover=false
lvl_complete=false

-- levels
levels={
 {
  recipe={[1]=1,[7]=1},
  ents={
   {id=1,t=0,x=64,y=100},
   {id=2,t=1,x=40,y=40},
   {id=3,t=7,x=88,y=40},
   {id=4,t=10,x=64,y=10,r=6}
  }
 },
 {
  recipe={[1]=1,[7]=1},
  ents={
   {id=1,t=0,x=64,y=110},
   {id=2,t=1,x=30,y=50},
   {id=3,t=7,x=98,y=50},
   {id=4,t=2,x=55,y=40},
   {id=5,t=2,x=73,y=40},
   {id=6,t=10,x=64,y=10,r=6}
  }
 }
}

function load_level(li)
 local l=levels[li]
 if not l then
  gameover=true
  msg="you win!"
  msg_t=999
  return
 end
 ents={}
 inv={} for i=1,9 do inv[i]=0 end
 fouls=0
 shots=0
 par=#l.ents+2
 mult=0
 input_lock=10
 state=3
 theta=0
 power=0
 charging=false
 cue=nil
 gameover=false
 lvl_complete=false
 recipe={}
 for k,v in pairs(l.recipe) do
  recipe[k]=v
 end
 for e in all(l.ents) do
  local ne={
   id=e.id,t=e.t,
   x=e.x,y=e.y,
   dx=0,dy=0,
   r=e.r or ball_r,
   cd=0,alive=true
  }
  add(ents,ne)
  if ne.t==0 then cue=ne end
 end
 msg="level "..li
 msg_t=60
end

function _init()
 state=-1
end

function show_msg(m,t)
 msg=m msg_t=t or 60
end

-- tally a hit (dynamic foul)
function eval_score(tt)
 if recipe[tt] and inv[tt]<recipe[tt] then
  inv[tt]+=1
 else
  fouls+=1
 end
end

-- entity colors by type
function ecol(t)
 local c=split"7,4,7,9,13,0,8,6,15,5,1"
 return c[t+1] or 7
end

-- ingredient names (index=type)
inames=split"cue,coffee,sugar,syrup,salt,pepper,hot sauce,cream,cinnamon,cocoa"

function _update60()
 if state==-1 then
  if btnp(4) or btnp(5) then
   lvl_idx=1
   global_score=0
   load_level(1)
  end
  return
 end

 if state==3 then
  if btnp(4) or btnp(5) then
   state=0
   input_lock=10
  end
  return
 end

 if msg_t>0 then msg_t-=1 end

 if gameover or lvl_complete then
  if btnp(4) or btnp(5) then
   if lvl_complete then
    lvl_idx+=1
    load_level(lvl_idx)
   else
    state=-1
   end
  end
  return
 end

 if state==0 then
  -- aim
  if input_lock>0 then
   input_lock-=1
   return
  end
  if btn(0) then theta-=0.01 end
  if btn(1) then theta+=0.01 end
  if btn(4) then
   charging=true
   power+=0.08
   if power>aim_pow_max then power=aim_pow_max end
  elseif charging then
   -- fire
   local ax=cos(theta)
   local ay=sin(theta)
   cue.dx=-ax*power
   cue.dy=-ay*power
   charging=false
   power=0
   shots+=1
   state=1
  end

 elseif state==1 then
  -- decrement cooldowns
  for e in all(ents) do
   if e.cd>0 then e.cd-=1 end
  end

  -- move
  for e in all(ents) do
   if e.alive and e.t!=10 then
    e.x+=e.dx
    e.y+=e.dy
    -- walls
    if e.x-e.r<0 then
     e.x=e.r
     e.dx=-e.dx*0.9
    end
    if e.x+e.r>127 then
     e.x=127-e.r
     e.dx=-e.dx*0.9
    end
    if e.y-e.r<0 then
     e.y=e.r
     e.dy=-e.dy*0.9
    end
    if e.y+e.r>127 then
     e.y=127-e.r
     e.dy=-e.dy*0.9
    end
   end
  end

  -- ball-ball collisions
  for i=1,#ents do
   for j=i+1,#ents do
    local a=ents[i]
    local b=ents[j]
    if a.alive and b.alive
    and a.t!=10 and b.t!=10 then
     local dpx=b.x-a.x
     local dpy=b.y-a.y
     local dsq=dpx*dpx+dpy*dpy
     local md=a.r+b.r
     if dsq<md*md and dsq>0.001 then
      local d=sqrt(dsq)
      local nx=dpx/d
      local ny=dpy/d
      local ov=md-d
      a.x-=nx*(ov/2)
      a.y-=ny*(ov/2)
      b.x+=nx*(ov/2)
      b.y+=ny*(ov/2)
      local rvx=a.dx-b.dx
      local rvy=a.dy-b.dy
      local van=rvx*nx+rvy*ny
      if van>0 then
       a.dx-=van*nx
       a.dy-=van*ny
       b.dx+=van*nx
       b.dy+=van*ny
      end
      -- scoring
      if a.t==0 and b.cd==0
      and b.t!=0 then
       eval_score(b.t)
       b.cd=cd_frames
      elseif b.t==0 and a.cd==0
      and a.t!=0 then
       eval_score(a.t)
       a.cd=cd_frames
      end
     end
    end
   end
  end

  -- pocket check
  for e in all(ents) do
   if e.t==10 then
    for b in all(ents) do
     if b.alive and b.t!=10 then
      local dpx=e.x-b.x
      local dpy=e.y-b.y
      local dsq=dpx*dpx+dpy*dpy
      if dsq<e.r*e.r then
       if b.t==0 then
        -- cue pocketed
        state=2
       else
        b.alive=false
       end
      end
     end
    end
   end
  end

  -- drag + stop
  local allstop=true
  for e in all(ents) do
   if e.alive and e.t!=10 then
    e.dx*=drag
    e.dy*=drag
    if abs(e.dx)<stopv
    and abs(e.dy)<stopv then
     e.dx=0 e.dy=0
    end
    if e.dx!=0 or e.dy!=0 then
     allstop=false
    end
   end
  end

  if state!=2 and allstop then
   state=2
  end

 elseif state==2 then
  -- evaluate
  local cue_pocketed=false
  for e in all(ents) do
   if e.t==10 then
    local dpx=e.x-cue.x
    local dpy=e.y-cue.y
    if dpx*dpx+dpy*dpy<e.r*e.r then
     cue_pocketed=true
    end
   end
  end

  if cue_pocketed then
   if fouls>0 then
    gameover=true
    show_msg("foul! bad mix!",999)
   else
    -- verify recipe complete
    local pass=true
    for k,v in pairs(recipe) do
     if (inv[k] or 0)<v then
      pass=false
     end
    end
    if pass then
     mult=max(1,par-shots+1)
     global_score+=1000*mult
     lvl_complete=true
     show_msg("level clear!",999)
    else
     gameover=true
     show_msg("recipe incomplete!",999)
    end
   end
  else
   -- cue stays where it stopped
   state=0
  end
 end
end

function _draw()
 cls(1)

 if state==-1 then
  print("barista billiards",22,30,7)
  print("- ingredient legend -",18,40,6)
  for i=1,9 do
   local row=flr((i-1)/3)
   local col=(i-1)%3
   local bx=6+col*42
   local by=52+row*12
   circfill(bx,by,3,ecol(i))
   circ(bx,by,3,0)
   print(inames[i+1],bx+6,by-2,6)
  end
  print("press \x8e or \x97 to start",24,96,7)
  return
 end

 if state==3 then
  rectfill(20,20,108,108,0)
  print("level "..lvl_idx.." recipe",30,25,7)
  local ry=38
  for k,v in pairs(recipe) do
   circfill(40,ry,3,ecol(k))
   circ(40,ry,3,0)
   print("x"..v,48,ry-2,7)
   print(inames[k+1] or "?",58,ry-2,6)
   ry+=12
  end
  print("press \x8e to start",30,95,7)
  return
 end

 -- draw pocket fills first
 for e in all(ents) do
  if e.t==10 and e.alive then
   circfill(e.x,e.y,e.r,0)
  end
 end

 -- draw balls
 for e in all(ents) do
  if e.alive and e.t!=10 then
   local c=ecol(e.t)
   circfill(e.x,e.y,e.r,c)
   circ(e.x,e.y,e.r,0)
   -- flash on cooldown
   if e.cd>0 and e.cd%4<2 then
    circ(e.x,e.y,e.r,10)
   end
  end
 end

 -- aim line
 if state==0 and not gameover
 and not lvl_complete then
  local ax=cos(theta)
  local ay=sin(theta)
  local lx=cue.x+ax*20
  local ly=cue.y+ay*20
  line(cue.x,cue.y,lx,ly,11)
  -- power bar
  local pw=power/aim_pow_max
  rectfill(2,120,2+pw*30,124,8)
  rectfill(2,120,32,124,7)
  rectfill(2,120,2+pw*30,124,11)
  print("power",2,114,7)
 end

 -- hud: recipe icons
 local hx=2
 for k,v in pairs(recipe) do
  for i=1,v do
   circfill(hx,4,3,ecol(k))
   circ(hx,4,3,0)
   if inv[k]>=i then
    -- green checkmark
    line(hx-1,4,hx,6,11)
    line(hx,6,hx+2,2,11)
   end
   hx+=9
  end
 end
 -- hud: stats (top right)
 print("fouls:"..fouls,88,2,8)
 print(shots.."/"..par,100,9,7)
 print(global_score,88,16,10)

 -- message
 if msg_t>0 then
  local w=#msg*4
  rectfill(64-w/2-2,58,
   64+w/2+2,68,0)
  print(msg,64-w/2,61,7)
 end

 -- gameover/clear overlay
 if gameover then
  rectfill(20,50,108,78,0)
  print("game over!",40,55,8)
  print("\x8e/\x97 to restart",32,68,6)
 elseif lvl_complete then
  rectfill(20,46,108,82,0)
  print("level clear!",36,49,11)
  print("bonus x"..mult,44,58,10)
  print("+"..1000*mult,50,66,10)
  print("\x8e/\x97 for next",36,74,6)
 end
end
