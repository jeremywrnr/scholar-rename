class Renamer
  def initialize(*args)
    a1 = args.first
    puts args
    @file = File.join(Dir.pwd, a1)

    if @file == Dir.pwd.to_s + '/'
      puts "scholar-rename: provide a file"
    elsif a1 == "-v"
      puts SR::Version
    else
      rename
    end
  end

  def rename # move file based on users input
    now = Time.now.to_i.to_s # current time, unique temp file
    temp = File.join(Dir.pwd, "temp-scholar-rename-text-#{now}")
    system("pdftotext -q '#{@file}' '#{temp}'")
    content = File.read temp

    # Choose pdf qualities
    s = Selector.new(content)
    s.select_all # choose props
    printf "Ok? [Yn]: "
    conf = STDIN.gets.chomp # confirm title

    begin # file read in from first ARGV above
      File.rename(@file, s.title) unless conf.match(/^(n|N).*/)
    ensure # cleaning up @file cleanup from pdftotext
      puts "Cleaning up..."
      File.delete(temp)
    end
  end
end
