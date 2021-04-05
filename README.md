# cr-unzip

Possibly fastest unzip tool in the world.

Written in Crystal.

## Installation

Use bin/cr-unzip (copy it somewhere in your $PATH).

Or, if it does not work for you, - install latest Crystal compiler according to instructions you may found at <https://crystal-lang.org/install/>

Than 
```
cd cr-unzip
crystal build -Dpreview_mt --release src/cr-unzip.cr -o bin/cr-unzip
```

## Usage
```
[CRYSTAL_WORKERS=$N_THREADS] cr-unzip [-q|-d] [-n $N_FIBERS] $ZIP_FILE_PATH
-q 	   Use queues to distribute jobs among threads
-d 	   Distribute equal count of unpacked files among threads
-x 	   Turn on debugging
-h 	   Show help message

$N_THREADS - number of os threads to use (aka N)
$N_FIBERS  - number of Crystal fibers to use (aka M)
$ZIP_FILE_PATH - path to your zip file. File name must have ".zip" extension
```

## Contributing

1. Fork it (<https://github.com/DRVTiny/cr-unzip/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Andrey A. Konovalov](https://github.com/DRVTiny) - creator and maintainer
