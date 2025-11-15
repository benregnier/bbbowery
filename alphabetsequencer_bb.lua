---alphabet sequencer
--start playback for outputs with start_playing() 
--stop playback on outputs with stop_playing()
--each channel is vertical - pitch on cv out, envelope on audio out, trigger on pulse out
--tempo is set by main knob unless you've patched a clock to cv 1
--try updating the sequins! add your own sequins to do other stuff!
--see comments below for which sequins do what

s = sequins
a = s{4, 6, 4, s{6, 8, 1, 11}} -- voice 1 pitch
b = s{2, 1, 3, 1, 1, 2} -- voice 1 timing
c = s{4, 1, 6, 1, 6} -- voice 2 pitch
d = s{2, 3, 2, 3, 2, 1} -- voice 2 timing

function init()
  --input[1].mode('clock')
  bpm = clock.tempo 
  check_clock()
end

function check_clock() --need to figure out how to turn off tempo
  --if bb.connected.cv1 then
  if bb.switch.position == 'up' then
    input[1].mode('clock')
  else
    input[1].mode('none')
    clock.tempo = (bb.knob.main * 200) + 1
  end
end

function start_playing()
  check_clock()
  coro_1 = clock.run(notes_event)
  coro_2 = clock.run(other_event)
end

function stop_playing()
  clock.cancel(coro_1)
  clock.cancel(coro_2)
end

function notes_event()
  while true do
    clock.sync(b())
    output[1].volts = a()/12
    output[1].slew = .1
    output[3].action = ar(0.01, 0.6, 5, 'lin')
    output[3]()
    bb.pulseout[1](pulse())
    check_clock()      
  end
end

function other_event()
  while true do
    clock.sync(d())
    output[2].volts = c()/12
    output[2].slew = .1
    output[4].action = ar(0.01, 0.5, 5, 'lin')
    output[4]()
    bb.pulseout[2](pulse())
  end
end






