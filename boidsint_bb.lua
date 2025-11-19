--- boids, the integer version
-- this shows how to implement this function with a minimum of floating point math
-- due to the nature of blackbird i'm not sure this actually provides performance improvements
-- original by t gill 190925, adapted

boids = {}
COUNT = 4 -- only first 4 are output


-- Q15 helpers
-- Q15 represents -1.0 .. +0.9999 as -32768 .. 32767
local Q15_ONE = 32768

local function q15_param01(x)
  -- x in [0,1], return x*Q15_ONE as integer
  return math.floor((x or 0) * Q15_ONE + 0.5)
end

-- multiply two Q15 integers → Q15
local function q15mul(a, b)
  return (a * b) // Q15_ONE
end

-- divide Q15 by positive integer → Q15
local function q15div(a, d)
  return a // d
end

local function clampQ15(x)
  if x >  32767 then return 32767 end
  if x < -32768 then return -32768 end
  return x
end

local function knob01(v)
  v = v or 0
  if v < 0 then return 0 end
  if v > 1 then return 1 end
  return v
end


-- Fixed params (not exposed via public)
local SYNC_Q   = q15_param01(1/20) -- constant sync
local LIMIT_Q  = q15_param01(0.05) -- velocity clamp
local TIMING_S = 0.02              -- base timing in seconds
-- avoidance from knob Y (0..1)
-- pull from knob X (0..1)
-- follow from main knob (0..1)


-- artificially provide a 'centre-of-mass'
local function centring(b, c)
  -- pull strength from knob X (0..1)
  local pull_q = q15_param01(knob01(bb.knob.x))
  local d = c - b.p
  return q15mul(d, pull_q)
end

-- avoidance(bs,b):
local function avoidance(bs, b)
  local v = 0
  -- avoid threshold from knob Y (0..1)
  local avoid_q = q15_param01(knob01(bb.knob.y))
  for n = 1, COUNT do
    local other = bs[n]
    if other ~= b then -- ignore self
      local d = other.p - b.p
      if math.abs(d) < avoid_q then
        -- v = v - d/2  (integer half)
        v = v - (d // 2)
      end
    end
  end
  return v
end

-- syncing(bs,b):
local function syncing(bs, b)
  local sum = 0
  for n = 1, COUNT do
    local other = bs[n]
    if other ~= b then
      sum = sum + other.v
    end
  end
  -- average of others
  local avg = q15div(sum, COUNT - 1)
  local d = avg - b.v
  return q15mul(d, SYNC_Q)
end

-- findcentre(bs,c):
local function findcentre(bs, c)
  local m = 0
  for n = 1, COUNT do
    m = m + bs[n].p
  end
  m = q15div(m, COUNT)

  -- follow strength from main knob (0..1)
  local follow_q = q15_param01(knob01(bb.knob.main))

  -- m + follow*(c - m)
  local diff = c - m
  return m + q15mul(diff, follow_q)
end

local function move(bs, n, c, v_mult_q15)
  local b = bs[n]

  -- sum forces 
  local dv =
        centring(b, findcentre(bs, c))
      + avoidance(bs, b)
      + syncing(bs, b)

  b.v = b.v + dv

  -- clamp velocity to ±limit
  if b.v > LIMIT_Q then
    b.v = LIMIT_Q
  elseif b.v < -LIMIT_Q then
    b.v = -LIMIT_Q
  end

  -- scale velocity by v_mult
  b.v = q15mul(b.v, v_mult_q15)

  -- update position
  b.p = clampQ15(b.p + b.v)

  return b
end


local function init_boids()
  local bs = {}
  for n = 1, COUNT do
    -- original was: math.random()*3.0 - 1.0
    -- In Q15, that's range -1.0 .. +2.0 => -Q15_ONE .. 2*Q15_ONE
    local p = math.random(-Q15_ONE, 2 * Q15_ONE)
    bs[n] = {
      p = p, -- position
      v = 0  -- velocity
    }
  end
  return bs
end

----------------------------------------------------------------
-- Main loop
----------------------------------------------------------------
local function boids_run()
  local bs = init_boids()
  local c_idx = 0

  while true do
    c_idx = (c_idx % COUNT) + 1  -- round-robin

    -- Convert input[1].volts (assumed -5..+5) to Q15 center:
    -- map -5..+5 → -1..+1       => center_q = (volts / 5) * Q15_ONE
    local in1 = input[1].volts or 0
    local center_q = math.floor((in1 / 5) * Q15_ONE + 0.5)

    -- v_mult: original was (input[2].volts + 5)/5  (0..2 range)
    -- map 0..2 → 0..2 as Q15 multiplier:
    local in2 = input[2].volts or 0
    local v_mult = (in2 + 5) / 5         -- 0..2 as float
    local v_mult_q15 = math.floor(v_mult * Q15_ONE + 0.5)

    -- update this boid
    bs[c_idx] = move(bs, c_idx, center_q, v_mult_q15)

    -- output: map position Q15 → volts (roughly -5..+5 like original)
    if c_idx <= 4 then
      output[c_idx].volts = (bs[c_idx].p / Q15_ONE) * 5.0
    end

    -- fixed timing (no public.timing)
    clock.sleep(TIMING_S / COUNT)
  end
end

----------------------------------------------------------------
-- init
----------------------------------------------------------------
function init()
  -- set slew based on TIMING_S (similar to old timing*2 behavior)
  for n = 1, 4 do
    output[n].slew = TIMING_S * 2
  end
  clock.run(boids_run)
end
