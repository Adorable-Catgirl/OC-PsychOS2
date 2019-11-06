function vt100emu(gpu) -- takes GPU component proxy *gpu* and returns a function to write to it in a manner like an ANSI terminal
 local mx, my = gpu.maxResolution()
 local cx, cy = 1, 1
 local pc = " "
 local lc = ""
 local mode = "n"
 local lw = true
 local sx, sy = 1,1
 local cs = ""

 -- setup
 gpu.setResolution(mx,my)
 gpu.fill(1,1,mx,my," ")

 function termwrite(s)
  s=s:gsub("\8","\27[D")
  pc = gpu.get(cx,cy)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0)
  gpu.set(cx,cy,pc)
  for i = 1, s:len() do
   local cc = s:sub(i,i)

   if mode == "n" then
    if cc == "\n" then -- line feed
     cx, cy = 1, cy+1
    elseif cc == "\r" then -- cursor home
     cx = 1
    elseif cc == "\27" then -- escape
     mode = "e"
    elseif string.byte(cc) > 31 and string.byte(cc) < 127 then -- printable, I guess
     gpu.set(cx, cy, cc)
     cx = cx + 1
    end

   elseif mode == "e" then
    if cc == "[" then
     mode = "v"
     cs = ""
    elseif cc == "D" then -- scroll down
     gpu.copy(1,2,mx,my-1,0,-1)
     gpu.fill(1,my,mx,1," ")
     cy=cy+1
     mode = "n"
    elseif cc == "M" then -- scroll up
     gpu.copy(1,1,mx,my-1,0,1)
     gpu.fill(1,1,mx,1," ")
     mode = "n"
    end

   elseif mode == "v" then
    if cc == "s" then -- save cursor
     sx, sy = cx, cy
     mode = "n"
    elseif cc == "u" then -- restore cursor
     cx, cy = sx, sy
     mode = "n"
    elseif cc == "H" then -- cursor home or to
     local tx, ty = cs:match("(.-);(.-)")
     tx, ty = tx or "1", ty or "1"
     cx, cy = tonumber(tx), tonumber(ty)
     mode = "n"
    elseif cc == "A" then -- cursor up
     cy = cy - (tonumber(cs) or 1)
     mode = "n"
    elseif cc == "B" then -- cursor down
     cy = cy + (tonumber(cs) or 1)
     mode = "n"
    elseif cc == "C" then -- cursor right
     cx = cx + (tonumber(cs) or 1)
     mode = "n"
    elseif cc == "D" then -- cursor left
     cx = cx - (tonumber(cs) or 1)
     mode = "n"
    elseif cc == "h" and lc == "7" then -- enable line wrap
     lw = true
    elseif cc == "l" and lc == "7" then -- disable line wrap
     lw = false
    end
    cs = cs .. cc
   end

   if cx > mx and lw then
    cx, cy = 1, cy+1
   end
   if cy > my then
    gpu.copy(1,2,mx,my-1,0,-1)
    gpu.fill(1,my,mx,1," ")
    cy=my
   end
   if cy < 1 then cy = 1 end
   if cx < 1 then cx = 1 end

   lc = cc
  end
  pc = gpu.get(cx,cy)
  gpu.setForeground(0)
  gpu.setBackground(0xFFFFFF)
  gpu.set(cx,cy,pc)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0)
 end

 return termwrite
end
