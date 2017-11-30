#!/usr/bin/env ruby

# togglesink - switch between analogue and bluetooth pulesaudio sinks
#
# Written in 2017 by Conrad Lukawski <conrad@backlight.ca>
#
# To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# This is a relatively simple script I wrote for myself to switch
# between regular audio out and a bluetooth audio sink in pulesaudio.
#
# This may or may not work for you, or it may just need some tweaking
# I don't know how many sinks you have, but I hope they're large double
# sinks so you have plenty of room to wash dishes and dry them.

require 'getoptlong'

# Let us get the cli args if we so want them
opts = GetoptLong.new(
  [ '--local', '-l', GetoptLong::NO_ARGUMENT ],
  [ '--bluetooth', '-b', GetoptLong::NO_ARGUMENT ]
)

# Helper method to remove the < > charactters from the pacmd sink names
# * *Args*    :
#   - +sink+ -> The string of the sink name you wish to switch to
#   - +inputs+ -> Array of active sink inputs to switch to the new sink, if any
#
def sink_switch(sink, inputs)
  # set the default sinkk
  `pactl set-default-sink #{sink}`

  # set any current audio input to the new default sink
  inputs.each do |input|
    `pacmd move-sink-input #{input} #{sink}`
  end
end

# Helper method to remove the < > charactters from the pacmd sink names
# * *Args*    :
#   - +sink_name+ -> This is the raw sink name from '$ pacmd list-sinks'
# * *Returns* :
#   - The sink name without the prefix and suffix < > characters
#
def clean_sink_name(sink_name)
  sink_name.slice!(0)
  sink_name = sink_name.slice(0..-3)
  sink_name
end  

# first get the sink names, this assumes you have 2, an alsa ouput and a bluetooth/bluez one
$alsa_sink = `pacmd list-sinks | awk '/name: <alsa/{print $2}'`
$bt_sink = `pacmd list-sinks | awk '/name: <bluez/{print $2}'`

# strip < > from string names... could use ranges but I think internally these are the same
# and this is more legible (also I think that just removes the bytes, not the characters)
# which would probably work fine here but let's just be sane; I guess .chop is also faster but hey
$alsa_sink = clean_sink_name($alsa_sink)
$bt_sink = clean_sink_name($bt_sink)

# find the current sink so we can determine what to switch to
$current_sink = `pacmd list-sinks | awk '/* index:/{print $3}'`.to_i

# Get the idle sink - this command is dumb but is the most legible
# Hope pacmd output doesn't change suddenly (thanks poettering)!
if $current_sink == 0 
  $idle_sink = `pacmd list-sinks | grep IDLE -B 5|grep index | awk '/index:/{print $3}'`.to_i
elsif $current_sink > 0
  $idle_sink = `pacmd list-sinks | grep IDLE -B 5|grep index | awk '/index/{print $2}'`.to_i
else
  # I'm sorry, this just isn't working out between us. It's pulesaudio, not me or you.
  at_exit { puts "Something is wrong with pacmd output or this just isn't going well for me/you or these scripts" }
  exit(false)
end

# Current playing sink inputs
$sink_inputs = `pacmd list-sink-inputs | awk '$1 == "index:" {print $2}'`.split("\n").map(&:to_i)

# Opts and switching logic
opts.each do |opt, arg|
  case opt
  when '--local'
    # set local hw as default sink #{alsa_sink}
    # `pactl set-default-sink #{alsa_sink}`
    sink_switch($alsa_sink, $sink_inputs)
  when '--bluetooth'
    # set bluetooth hw as default sink
    # `pactl set-default-sink #{bt_sink}`
    sink_switch($bt_sink, $sink_inputs)
  end
end

# If we don't have any arguments, just toggle between the two sinks
if ARGV.length != 1
  if $current_sink > 0
    # currently bluetooth, set local hw as default sink
    # `pactl set-default-sink #{alsa_sink}`
    sink_switch($alsa_sink, $sink_inputs)
  else
    # currently local, set bluetooth hw as default sink
    # `pactl set-default-sink #{bt_sink}`
    sink_switch($bt_sink, $sink_inputs)
  end
end

# Goodbye!
exit 0
