# bowery
[druid](https://github.com/monome/druid) script collection, specific to the "blackbird" variant of crow for use with the [MTM Workshop System Computer module](https://www.musicthing.co.uk/Computer_Program_Cards/)  

Info on blackbird and how to install can be found on the [MTM Github](https://github.com/TomWhitwell/Workshop_Computer/tree/main/releases/41_blackbird).  

Blackbird has some limitations with relationship to crow (audio rate scripts will experience significant distortion, no ii support) but also has some advantages (additional inputs and ouputs, panel controls, LED feedback). These scripts have been modified to take advantage of some of the additional features.  

- [alphabetsequencer.lua](alphabetsequencer.lua): sequence synth voices with sequins
- [boids.lua](boids.lua): four simulated birds that fly around your input
- [booleans.lua](booleans.lua): logic gates determined by two input gates
- [clockdiv.lua](clockdiv.lua): four configurable clock divisions of the input clock
- [cvdelay.lua](cvdelay.lua): a control voltage delay with four taps & looping option
- [euclidean.lua](euclidean.lua): a euclidean rhythm generator
- [gingerbread.lua](gingerbread.lua): clocked chaos generators
- [krahenlied.lua](krahenlied.lua): sequence synth voices with poetry
- [lorenz.lua](lorenz.lua): lorenz attractor chaotic lfos
- [quantizer.lua](quantizer.lua): a continuous and clocked quantizer demo
- [samplehold.lua](samplehold.lua): sample and hold basics for scripting tutorial
- [seqswitch.lua](seqswitch.lua): route an input to 1 of 4 outputs with optional 'hold'
- [shiftregister.lua](shiftregister.lua) (*): output the last 4 captured voltages & play just friends
- [timeline.lua](timeline.lua): timeline sequencer

learn how to upload scripts to crow using [***stage one*** of the crow scripting tutorial](https://monome.org/docs/crow/scripting)
