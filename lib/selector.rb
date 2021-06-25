# Class for choosing and displaying the information from the pdf.
# I wonder if this could be augmented with information from google scholar
# somehow, there is probably a ruby (or at least python) api.

class Selector
  attr_reader :title
  attr_accessor :content, :options

  def initialize(c = "", opts = { :format => 0, :auto => true })
    set_content(c)
    @fulltxt = c.split("\n")
    @options = opts
  end

  def set_content(str)
    @content = str.split("\n")[0..14]
      .reject { |x| x.length < 2 }
      .map { |x| x[0..100] } # trim
  end

  def select_all
    puts "Options:"
    @content.each_with_index { |l, i| puts "#{i}\t#{l}" }
    printf "Select title line number "
    title = choose(@content, print: false)

    printf "Select author line number "
    authors = choose(@content, print: false)

    puts "Select author form:"
    author = gen_authors(authors)

    year = gen_year # just read it

    forms = gen_forms(year, title, author)
    @title = forms[@options[:format]]
  end

  # based on the collected information, generate different forms of the title.
  def gen_forms(y, t, a)
    ad = a.downcase
    au = a.upcase
    return [
             "#{y} - #{a} - #{t}.pdf",
             "#{y} #{a} #{t}.pdf",
             "#{a}_#{y}_#{t}.pdf".gsub(" ", "_"),
             "#{au}_#{y}_#{t}.pdf".gsub(" ", "_"),
             "#{ad}_#{y}_#{t}.pdf".gsub(" ", "_"),
             "#{a} #{y} #{t}.pdf",
             "#{au} #{y} #{t}.pdf",
             "#{ad} #{y} #{t}.pdf",
           ]
  end

  # Pass in an array to list and be selected, and return the element that the
  # user selects back to the calling method. this is a way to interpret
  # the users input as a range (e.g., 0..2) or an integer (1).
  def choose(options, print: true)
    return "Null options" if options.length == 0
    if print
      options.each_with_index { |l, i| puts "#{i}\t#{l}" }
      printf "[0 - #{options.length - 1}]: "
    end

    if !auto
      line = STDIN.gets.chomp || 0
    else
      line = 0
    end

    meta = "options[#{line}]"
    mout = eval meta
    mout.join " " if mout.is_a? (Array)
    mout
  end

  # Generate different forms for author selection, enumerating the different
  # author that you want to save the file as. Split based on a comma.
  def gen_authors(aline)
    lines = aline.split(", ").map { |a| a.sub(/\d$/, "") } # delete ref number.
    if lines.is_a?(String)
      aline
    else # its an array, augment w/ lname and choose
      alines = lines.map { |a| a.split.last } + lines
      choose alines
    end
  end

  # Parse out a year from a string, for each line of the document until found.
  # Then clean it up and return it.
  def gen_year
    @fulltxt.each do |l| # find year
      lm = l.match(/(19|20)\d\d/)
      return lm[0] if !lm.nil?
    end

    Time.now.year.to_s # not matched, just return current year
  end
end
