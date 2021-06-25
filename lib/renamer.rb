require_relative "./version.rb"

class Renamer
  attr_reader :version, :formats, :selector, :format

  def initialize(*args)
    args = args.flatten
    a0 = args.first
    al = args.last

    @real_file = false
    @options = { :format => 0, :auto => false, :debug => false, :test => false }
    @version = SR::Version
    @selector = Selector.new
    @formats = @selector.gen_forms("Year", "Title", "Author")

    if args.include? "--debug"
      @options[:debug] = true
    end

    if args.include? "--test"
      @options[:test] = true
      def puts(*x) x; end
    end

    # Filename comes last.
    if !al.nil? && al[0] != "-"
      @file = File.join(Dir.pwd, args.last).to_s
      @real_file = @file && File.file?(@file)
    end
    if @file && !@real_file
      puts "Input #{@file} not found."
      puts "Please specify a pdf file to use with scholar-rename."
      exit 1
    end

    # Main argument processing.
    if args.length == 0 || a0 == "--h" || a0 == "--help"
      puts "usage: scholar-rename (--format #) (--auto) [file.pdf]"
      puts "\t--show-formats\tshow format options"
      puts "\t--auto\tpick default formatter"
      puts "\t-v, --version\tshow version number"
    elsif a0 == "-v" || a0 == "--version"
      puts @version
      exit 0 unless @options[:test]
    elsif !has_prereq?
      puts "please install pdftotext (via poppler) to use scholar-rename"
      puts "OSX: brew install pkg-config poppler"
      exit 1
    elsif a0 == "--show-formats"
      @formats.each_with_index { |x, i| puts "\t#{i}: #{x}" }
    elsif a0 == "--format"
      @options[:format] = args[1].to_i
    elsif a0 == "--auto"
      @options[:auto] = true
    end

    rename args if @real_file
  end

  def has_prereq?
    system("pdftotext -v 2> /dev/null")
    $?.success?
  end

  def rename(args)
    raw = `pdftotext -q '#{@file}' -` # may contain non-ascii characters
    content = raw.encode("UTF-8", :invalid => :replace, :undef => :replace)
    
    # Choose pdf qualities
    @selector.set_content(content)
    @selector.options = @options
    @selector.select_all
    md = @selector.metadata

    if @options[:debug]
      puts md[:year] if args.include? "--show-year"
      puts md[:title] if args.include? "--show-title"
      puts md[:author] if args.include? "--show-author"
    else
      File.rename(@file, @selector.title)
      puts "Saved #{@selector.title}"
    end
  end
end
