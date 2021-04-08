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
cr-unzip 
	[-p JOB_DISTR_POLICY] [-n N_FIBERS] [-d TARGET_DIR] zip_file_path
		or
	-h
-p, --policy qu[eue] | eq[ual]
	Use the specified job distribution policy: queued or equal(-sized)
-d, --destination TARGET_PATH
	Specify target directory for unpack. By default zip file will be unpacked to the current working directory
-x	Turn on debug output
-h	Show help message
```

## Contributing

1. Fork it (<https://github.com/DRVTiny/cr-unzip/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Andrey A. Konovalov](https://github.com/DRVTiny) - creator and maintainer
