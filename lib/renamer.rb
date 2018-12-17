require_relative "./version.rb"

class Renamer
  attr_reader :vers, :formats, :selector, :format
  def initialize(*args)
    a0 = args.first

    @opts = {}
    @vers = SR::Version
    @file = File.join(Dir.pwd, args.last)
    @selector = Selector.new
    @formats = @selector.gen_forms("Year", "Title", "Author")

    if a0 == "-v" || a0 == "--version"
      puts @vers
      return self
    elsif a0 == "--format" && args.length == 1
      @formats.each_with_index {|x, i| puts "\t#{i}: #{x}"}
      return self
    elsif @file == Dir.pwd.to_s + '/'
      puts "usage: scholar-rename (--format #) [file.pdf]"
      puts "\t--format\tshow format options"
      puts "\t-v\tshow version number"
    elsif has_prereq?
      puts "please install pdftotext to use scholar-rename"
      puts "osx: brew install xpdf"
    elsif a0 == "--format" && args.length > 1
      @format = args[1].to_i
    end
  end

  def has_prereq?
    system("pdftotext 2> /dev/null")
    $?.success?
  end

  def rename
    raw = `pdftotext -q '#{@file}' -` # may contain non-ascii characters
    content = raw.encode('UTF-8', :invalid => :replace, :undef => :replace)

    # for debugging
    #now = Time.now.to_i.to_s # current time, unique temp file
    #temp = File.join(Dir.pwd, "temp-scholar-rename-text-#{now}")
    #system("pdftotext -q '#{@file}' '#{temp}'")

    # Choose pdf qualities
    @selector.set_content(content)
    @selector.options = {:format => @format} if @format
    @selector.select_all # choose props

    if !@@TESTING
      puts @file, @selector.title
    else
      File.rename(@file, @selector.title)
    end
  end
end
