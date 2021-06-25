require_relative "./version.rb"

class Renamer
  attr_reader :version, :formats, :selector, :format

  def initialize(*args)
    args = args.flatten
    a0 = args.first

    @opts = { :format => 0, :auto => false }
    @version = SR::Version
    @selector = Selector.new
    @formats = @selector.gen_forms("Year", "Title", "Author")

    if !args.last.nil? && args.last[0] != "-"
      @file = File.join(Dir.pwd, args.last).to_s
    end

    if @file && !File.file?(@file)
      puts "Input #{@file} not found."
      puts "Please specify a pdf file to use with scholar-rename."
      exit 1
    end

    if args.includes "--debug"
      @debug = true
    end

    if args.length == 0 || a0 == "--h" || a0 == "--help"
      puts "usage: scholar-rename (--format #) (--auto) [file.pdf]"
      puts "\t--show-formats\tshow format options"
      puts "\t--auto\tpick default formatter"
      puts "\t-v, --version\tshow version number"
    elsif a0 == "-v" || a0 == "--version"
      puts @version
    elsif !has_prereq?
      puts "please install pdftotext (via poppler) to use scholar-rename"
      puts "OSX: brew install pkg-config poppler"
      exit 1
    elsif a0 == "--show-formats"
      @formats.each_with_index { |x, i| puts "\t#{i}: #{x}" }
    elsif a0 == "--format"
      @opts.format = args[1].to_i
    elsif a0 == "--auto"
      @opts.auto = true
    end

    rename
  end

  def has_prereq?
    system("pdftotext -v 2> /dev/null")
    $?.success?
  end

  def rename
    raw = `pdftotext -q '#{@file}' -` # may contain non-ascii characters
    content = raw.encode("UTF-8", :invalid => :replace, :undef => :replace)

    # Choose pdf qualities
    @selector.set_content(content)
    @selector.options = @options
    @selector.select_all

    if @debug
    else
      File.rename(@file, @selector.title)
      puts "Saved #{@selector.title}"
    end
  end
end
