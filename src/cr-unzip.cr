# Build me this way:
# $	crystal build -Dpreview_mt --release unzip_fiberized.cr
# And run me in this manner:
# $ CRYSTAL_WORKERS=$(nproc) ./unzip_fiberized.cr path/to/file.zip
require "compress/zip"
require "option_parser"
require "app_name"

lib LibC
	fun fflush(b : Void*)
	#		fun printf(format : Char*, ...) : Int32
end

module ZipUnpackFiberized
	VERSION = "0.0.1"
	@@fl_debug = false
	
  def self.log(s)
		t = Thread.current.to_s rescue "Unknown"
		f = Fiber.current.to_s rescue "Unknown"
		LibC.printf("%s::%s >>> %s\n", t, f, s)
		LibC.fflush(nil)
  end
  
  def self.unpack_file(z_entry : Compress::Zip::File::Entry)
		log "extracting file #{z_entry.filename}" if @@fl_debug
		File.open(z_entry.filename, "w") do |unpacked_file|
			z_entry.open do |z_io|
				IO.copy z_io, unpacked_file
			end
		end  	
  end
  
  fl_use_queue = false
  fl_use_div_et_imp = false
  n_fibers = 0
	OptionParser.parse do |parser|
		parser.banner = "Usage: #{AppName.exec_name} [arguments]"
		parser.on("-q", "--queue", "Use queue to distribute jobs among threads") { fl_use_queue = true }
		parser.on("-d", "--divetimpera", "Use divide et impera policy to distribute jobs among threads") { fl_use_div_et_imp = true }
		parser.on("-n N_FIBERS", "--fibers=N_FIBERS", "Number of fibers to use") do |n|
			n_fibers = n.to_i
			raise "invalid number of fibers: must be >1" if n_fibers <= 1
		end
		parser.on("-x", "--debug", "Turn on debugging") { @@fl_debug = true }
		parser.on("-h", "--help", "Show this help message") do
			puts parser
			exit
		end
		parser.invalid_option do |flag|
			STDERR.puts "ERROR: #{flag} is not a valid option."
			STDERR.puts parser
			exit(1)
		end
	end
	n_fibers = Crystal::System.cpu_count if n_fibers == 0
	if fl_use_queue && fl_use_div_et_imp
		raise "You cant specify both --queue and --divetimpera: this options is mutual exclusive"
	elsif ! (fl_use_queue || fl_use_div_et_imp)
		fl_use_div_et_imp = true
	end
	
	if ARGV[0]?
		zip_file_pth = ARGV[0]
	else
		raise "You must specify zip file path as a last argument"
	end
	
	zip_file_pth =~ /\.zip$/ || raise "file extension must be '.zip'"
	
	Compress::Zip::File.open(zip_file_pth) do |zip_file|
		files2extract = [] of Compress::Zip::File::Entry
		zip_file.entries.each do |ze|
			if (pth = ze.filename) =~ /\/$/
				Dir.mkdir_p pth
			else
				files2extract.push ze
			end
		end
		
		ch_end = Channel(Nil).new		
		n_fibers = Crystal::System.cpu_count
		if fl_use_div_et_imp
			n_files = files2extract.size 
			n_files_per_thread =  n_files // n_fibers
			rmn_files =           n_files % n_fibers
			si, ei = 0, 0
			n_fibers.times do
				ei = si + n_files_per_thread + (rmn_files > 0 ? 1 : 0) - 1
				rmn_files -= 1
				ssi, eei = si, ei
				spawn do
					(ssi..eei).each do |i|
						unpack_file files2extract[i]
					end
					ch_end.send(nil)
				end
				si = ei + 1
			end
		else
			ch_buf_size = files2extract.size + n_fibers
			ch_files = Channel(Compress::Zip::File::Entry | Nil).new(ch_buf_size)
			
			files2extract.each {|ze| ch_files.send(ze)  }
			n_fibers.times       {     ch_files.send(nil) }
			n_fibers.times do
				spawn do
					while	z_entry = ch_files.receive
						unpack_file z_entry
					end
					ch_end.send(nil)
				end
			end			
		end
		
		n_fibers.times { ch_end.receive }
	end # <- Compress::Zip::File.open(zip_file_pth)
end
