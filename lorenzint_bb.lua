--- lorenz attractor TODO implement in integer math
-- sam wolk 2019.10.13
-- in1 resets the attractor to the {x,y,z} coordinates stored in the Lorenz.origin table
-- in2 controls the speed of the attractor
-- out1 is the x-coordinate (by default)
-- out2 is the y-coordinate (by default)
-- out3 is the z-coordinate (by default)
-- out4 is a weighted sum of x and y (by default)
-- the weights table allows you to specify the weight of each axis for each output.

weights = {
  {toFixed(1), 0, 0},
  {0, toFixed(1), 0},
  {0, 0, toFixed(1)},
  {toFixed(0.33), toFixed(0.33), 0}
}

Lorenz = {
  -- origin = {0.01, 0, 0} -> scaled
  origin = {toFixed(0.01), 0, 0},

  -- parameters (scaled)
  sigma = toFixed(10.0),      -- 10
  rho   = toFixed(28.0),      -- 28
  beta  = toFixed(8/3),       -- 2.666...

  state = {toFixed(0.01), 0, 0},

  steps = 1,

  -- dt as fixed-point: 0.001 -> 0.001 * SCALE
  dt = toFixed(0.001),
}


local SCALE = 10000  -- all fixed-point values are real * SCALE

local function toFixed(x)
  return math.floor(x * SCALE + 0.5)
end

local function fromFixed(x)
  return x / SCALE
end

-- fixed-point multiply: (a * b) / SCALE
local function mulFixed(a, b)
  return (a * b) // SCALE      -- integer division
end

-- fixed-point multiply by plain integer (no extra SCALE division)
local function mulFixedInt(a, k)
  return a * k                 -- k is not scaled
end


function Lorenz:process(steps, dt)
  steps = steps or self.steps
  dt = dt or self.dt      -- both fixed-point

  for i = 1, steps do
    local x = self.state[1]
    local y = self.state[2]
    local z = self.state[3]

    -- dx = sigma * (y - x)
    local dx = mulFixed(self.sigma, (y - x))

    -- dy = x * (rho - z) - y
    local dy = mulFixed(x, (self.rho - z)) - y

    -- dz = x * y - beta * z
    local dz = mulFixed(x, y) - mulFixed(self.beta, z)

    -- x += dx * dt
    x = x + mulFixed(dx, dt)
    y = y + mulFixed(dy, dt)
    z = z + mulFixed(dz, dt)

    self.state[1] = x
    self.state[2] = y
    self.state[3] = z
  end
end


function Lorenz:reset()
  for i = 1, 3 do
    self.state[i] = self.origin[i]
  end
end

updateOutputs = function()
  for i = 1, 4 do
    local sum = 0
    for j = 1, 3 do
      -- sum += weight * state  (both fixed)
      sum = sum + mulFixed(weights[i][j], Lorenz.state[j])
    end

    -- Now sum is fixed-point; convert back to float for `output.volts`
    local sum_real = fromFixed(sum)

    -- same scaling as original, but in float at the very end
    output[i].volts = 10 * (sum_real + 25) / 80 - 5
  end
end


input[1].change = function(s)
  Lorenz:reset()
end

input[2].stream = function(volts)
  local dt_real = math.exp((volts - 1) / 3) / 1000 - 0.00005
  -- clamp dt
  if dt_real < 0.00001 then dt_real = 0.00001 end
  if dt_real > 0.01    then dt_real = 0.01    end
  Lorenz.dt = toFixed(dt_real)
end


function init()
  Lorenz:reset()
  input[1].mode('change', 1,0.1,'rising')
  input[2].mode('stream',0.001)
  clock.run( function()
    while true do
      Lorenz:process()
      updateOutputs()
      clock.sleep(0.001)
    end
  end)
end
