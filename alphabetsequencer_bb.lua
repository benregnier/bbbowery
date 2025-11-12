---alphabet sequencer
--start playback for outputs 1-4 with start_playing() 
--or start eveything at once with start_everything() 
--stop playback on outputs 1-4 with stop_playing() 
--stop playback on just friends with stop_jf() 
--stop playback on w/syn with stop_with
--or stop everything at once with stop_everything()
--try updating the sequins!
--see comments below for which sequins do what
s = sequins
a = s{4, 6, 4, s{6, 8, 1, 11}} -- voice 1 pitch
b = s{2, 2, 2, 2, 2, 2} -- voice 1 timing
c = s{4, 1, 6, 1, 6} -- voice 2 pitch
d = s{2, 2, 2, 2, 2, 2} -- voice 2 timing

function init()
  input[1].mode('clock')
  bpm = clock.tempo 
  bb.switch.change = function(position)
    if position == 'down' then
      stop_playing()
    elseif position == 'middle' then
      start_playing()
      input[1].mode('clock')
    else
      input[1].mode('stream')
 
end
function start_playing()
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
    output[3].action = ar(1, 1, 5, 'lin')
    output[3]()
    bb.pulseout[1](pulse())
    if bb.switch.position == 'up' then
      clock.tempo = (bb.knob.main * 200) + 1
  end
end
function other_event()
  while true do
    clock.sync(d())
    output[2].volts = c()/12
    output[2].slew = .1
    output[4].action = ar(1, 1, 5, 'lin')
    output[4]()
    bb.pulseout[2](pulse())
  end
end
end


