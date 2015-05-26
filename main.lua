require("loveshortcuts")
I = require("inspect")
LOVEBIRD = require("lovebird")

time = 0


--zoom variables
width = love.window.getWidth()
height = love.window.getHeight()

w = 5
h = (w * height) / width

xmin = -w/2
ymin = -h/2

rng = love.math.newRandomGenerator(os.time())
function random(low,high) return rng:random(low,high) end

--colorization
col1 = random(1,255)
col2 = random(1,255)
col3 = random(1,255)

--infty threshold
infty = 16

function love.load()
  width = love.window.getWidth()
  height = love.window.getHeight()
  can = lg.newCanvas()
	-- Establish a range of values on the complex plane
  -- A different range will allow us to "zoom" in or out on the fractal

  -- It all starts with the width, try higher or lower values

  -- Start at negative half the width and height

  -- Maximum number of iterations for each point on the complex plane
  maxiterations = 1000

  -- x goes from xmin to xmax
  xmax = xmin + w
  -- y goes from ymin to ymax
  ymax = ymin + h

  -- Calculate amount we increment x,y for each pixel
  dx = (xmax - xmin) / (width);
  dy = (ymax - ymin) / (height);

  pixels = {}

  calculateFrac()
end

function calculateFrac()
  y = ymin
  for j = 0,height do
    -- Start x
    x = xmin
    for i = 0,width do

      -- Now we test, as we iterate z = z^2 + cm does z tend towards infinity?
      a = x
      b = y
      n = 0
      continue = true
      while n < maxiterations and continue do
        aa = a * a 
        bb = b * b 
        twoab = 2.0 * a * b;
        a = aa - bb + x
        b = twoab + y
        -- Infinty in our finite world is simple, let's just consider it 16
        if aa + bb > infty then
          --bail
          continue = false
        end
        n = n + 0.3
      end

      -- We color each pixel based on how long it takes to get to infinity
      -- If we never got there, let's pick the color black
      if n > maxiterations then 
        pixels[i+j*width] = 0;
      else
        -- Gosh, we could make fancy colors here if we wanted
        pixels[i+j*width] = n--*16 * i * j;
      end
      x = x + dx
    end
    y = y + dy
  end

  --draw to canvas
  can:clear()
  lg.setCanvas(can)
  local x = 0
  local y = 0
  for i=1, #pixels do
    lg.setColor((pixels[i]*col1)%255,(pixels[i]*col2)%255,(pixels[i]*col3)%255)
    lg.point(x,y)
    
    x = (x + 1) % width
    if x == 0 then y = y + 1 end
  end
  lg.setCanvas()

end


function love.update(dt)
  time = time + dt
  LOVEBIRD.update()
  love.window.setTitle( love.timer.getFPS( ) )
end

function love.keypressed(key)
  print(key)
  if key == "c" then
    col1 = random(1,255)
    col2 = random(1,255)
    col3 = random(1,255)
    love.load()
  end

  if key == "+" then
    infty = infty + 1
    love.load()
  end

  if key == "-" then
    infty = infty - 1
    love.load()
  end
end

function love.mousepressed(x, y, key)
  mousestartx,mousestarty = x,y
end

function love.mousereleased(x,y,key)
  xmin = xmin + ((mousestartx)*dx)
  ymin = ymin + ((mousestarty)*dy)

  print(xmin)
  print(ymin)

  w = (x-mousestartx)*dx
  h = (y-mousestarty)*dy

  print (w)
  print(h)

  mousestartx,mousestarty = nil,nil
  love.load()
end

function love.resize()
  love.load()
end

function love.draw()
  lg.setColor(255,255,255)
  lg.draw(can)

  local x,y = lm.getPosition()

  lg.print("xmin:" .. (((x/width)-0.5)*w)-0.25*w)
  lg.print("ymin:" .. (((y/height)-0.5)*h)-0.25*h,0,20)
  lg.print("col1:" .. col1, 0, 40)
  lg.print("col2:" .. col2, 0, 60)
  lg.print("col3:" .. col3, 0, 80)
  lg.print("infinity threshold:" .. infty, 0, 100)

  if mousestartx and mousestarty then
    lg.rectangle("line", mousestartx, mousestarty, x-mousestartx, y-mousestarty)
  end
end
