require_relative "./version.rb"

class Renamer
  attr_reader :vers
  def initialize(*args)
    a1 = args.first
    @file = File.join(Dir.pwd, a1)
    @vers = SR::Version

    if a1 == "-v"
      puts @vers
      return self
    elsif @file == Dir.pwd.to_s + '/'
      puts "usage: scholar-rename [pdf_file]"
      puts "please specify a pdf file"
    elsif has_prereq?
      puts "please install pdftotext to use scholar-rename"
      puts "osx: brew install xpdf"
    else
      rename a1
    end
  end

  def has_prereq?
    system("pdftotext 2> /dev/null")
    $?.success?
  end

  def rename(opts)
    raw = `pdftotext -q '#{@file}' -` # may contain non-ascii characters
    content = raw.encode('UTF-8', :invalid => :replace, :undef => :replace)

    # for debugging
    #now = Time.now.to_i.to_s # current time, unique temp file
    #temp = File.join(Dir.pwd, "temp-scholar-rename-text-#{now}")
    #system("pdftotext -q '#{@file}' '#{temp}'")

    # Choose pdf qualities
    s = Selector.new(content, opts)
    s.select_all # choose props

    # Final title confirm
    #printf "Ok? [Yn]: "
    #conf = STDIN.gets.chomp
    #unless conf.match(/^(n|N).*/)
    #begin
    #ensure
    #puts "Cleaning up..."
    #File.delete(temp)
    #end

    File.rename(@file, s.title)
  end
end
