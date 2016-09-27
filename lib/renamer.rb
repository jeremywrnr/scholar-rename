class Renamer
  def initialize(*args)
    @file = args.first
  end

  def rename # move file based on users input
    now = Time.now.to_i.to_s # current time
    temp = "temp-scholar-rename-text-#{now}"
    system("pdftotext -q #{@file} #{temp}")
    content = File.read temp

    # Choose pdf qualities
    s = Selector.new(content)
    s.select # choose props
    printf "Ok? [Yn]: "
    conf = STDIN.gets.chomp # confirm title

    begin # file read in from first ARGV above
      File.rename(@file, s.title) unless conf.match /^(n|N).*/
    ensure # cleaning up @file cleanup from pdftotext
      puts "Cleaning up..."
      File.delete(temp)
    end
  end
end
