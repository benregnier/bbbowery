--- quantizer
-- sam wolk 2019.10.15
-- updated by whimsicalraps 2021
-- adapted by qben for bb 2025
-- cv in 1: clock
-- cv in 2: voltage to quantize
-- cv out 1: in2 quantized to scale1 on clock pulses, 
-- cv out 2: in2 quantized to scale2 on clock pulses
-- audio out 1: in2 quantized to scale3 continuously
-- audio out 2: trigger pulses when out3 changes

-- add your scales here!
scales =
{ {0}               -- octaves
, {}                -- chromatic
, {0,2,4,5,7,9,11}  -- major
, {0,2,3,5,7,8,10}  -- harmonic minor
, {0,2,3,5,7,9,10}  -- dorian
, {0,4,7}           -- major triad
, {0,4,7,10}        -- dominant 7th
, {0,2,4,6,8,10}    -- whole tone
}

-- update clocked outputs
input[1].change = function(state)
  output[1].volts = input[2].volts
  output[2].volts = input[2].volts
end

-- update continuous quantizer
input[2].scale = function(s)
  output[3].volts = s.volts
  output[4]()
  setScales()
end

function init()
  input[1].mode('change',1,0.1,'rising')
  setScales()
  output[4].action = pulse(0.01, 8)
end

function tableIndex(v, c)
  if value < 0 then value = 0 end
  if value > 1 then value = 1 end
  local idx = math.floor(value * (l - c)) + 1
  return idx
end

function setScales()
  local count = #scales
  output[1].scale(scales[tableIndex(bb.Knob.Main,count)])
  output[2].scale(scales[tableIndex(bb.Knob.X,count)]) 
  input[2].scale(scales[tableIndex(bb.Knob.Y,count)])  
end
  

