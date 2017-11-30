# togglesink

This is a relatively simple ruby script I wrote for myself to switch
between regular audio sink and a bluetooth audio sink in pulesaudio.

The script also moves any current sink inputs to the new sink.

This may or may not work for you, or it may just need some tweaking
I don't know how many sinks you have, but I hope they're large double
sinks so you have plenty of room to wash dishes.

## Usage

#### Mark the script as executable:

```sh
$ chmod +x ./togglesink.rb
```

#### To simply toggle between sinks:

```sh
$ ./togglesink.rb
```

#### To manually switch to local audio sink:

```sh
$ ./togglesink.rb -l
```
*Note: the long --local option can also be used.*

#### To manually switch to the bluetooth sink

```sh
$ ./togglesink.rb -b
```
*Note: the long --bluetooth option can also be used.*

## Documentation

The script is pretty well documented but feel free to shoot me a line if I can help at all.

## License

The work done has been licensed under Creative Commons CC0. The license file can be found here. You can find out more about the license at http://creativecommons.org/publicdomain/zero/1.0/
