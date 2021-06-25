require_relative "./version.rb"

class Renamer
  @@TESTING = false

  attr_reader :version, :formats, :selector, :format
  def initialize(*args)
    args = args.flatten
    a0 = args.first

    @opts = {}
    @version = SR::Version
    @selector = Selector.new
    @formats = @selector.gen_forms("Year", "Title", "Author")

    if !args.last.nil? && args.last[0] != "-"
      @file = File.join(Dir.pwd, args.last).to_s
    end

    if @file && !File.file?(@file)
      puts "Input #{@file} not found."
      exit 1
    end

    if args.length == 0 || a0 == "--h" || a0 == "--help"
      puts "usage: scholar-rename (--format #) (--auto) [file.pdf]"
      puts "\t--format\tshow format options"
      puts "\t--auto\tpick default formatter"
      puts "\t-v, --version\tshow version number"
    elsif a0 == "-v" || a0 == "--version"
      puts @version
    elsif !has_prereq?
      puts "please install pdftotext (via poppler) to use scholar-rename"
      puts "brew install pkg-config poppler"
      exit 1
    elsif a0 == "--format" && args.length == 1
      @formats.each_with_index {|x, i| puts "\t#{i}: #{x}"}
    elsif a0 == "--format" && args.length > 1
      @format = args[1].to_i
    elsif a0 == "--auto" == arg.length > 1
      puts "please also provide a pdf file to use scholar-rename"
      exit 1
    elsif a0 == "--auto" && arg.length > 1
      @format = 0
    end

    if @file && File.file?(@file)
      rename
    end
  end

  def has_prereq?
    system("pdftotext -v 2> /dev/null")
    $?.success?
  end

  def rename
    raw = `pdftotext -q '#{@file}' -` # may contain non-ascii characters
    content = raw.encode('UTF-8', :invalid => :replace, :undef => :replace)
    
    # Choose pdf qualities
    @selector.set_content(content)
    @selector.options = {:format => @format} if @format
    @selector.select_all # choose props
    
    if @@TESTING
      # for debugging
      #now = Time.now.to_i.to_s # current time, unique temp file
      #temp = File.join(Dir.pwd, "temp-scholar-rename-text-#{now}")
      #system("pdftotext -q '#{@file}' '#{temp}'")
      puts @file, @selector.title
    else
      File.rename(@file, @selector.title)
      puts "Saved #{@selector.title}"
    end
  end
end
