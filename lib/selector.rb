# Class for choosing and displaying the information from the pdf.
# I wonder if this could be augmented with information from google scholar
# somehow, there is probably a ruby (or at least python) api.

class Selector
  attr_reader :title

  # take the first 10 lines of the pdftotext output and assign it to the
  # context class instance variable, use later when choosing selector
  def initialize(c)
    @content = c.split("\n")[0..14].reject {|x| x.length < 2 }
    @fulltxt = c.split("\n")
  end

  def select_all
    puts "Select title line number:"
    title = choose @content

    puts "Select author line number:"
    authors = choose @content

    puts "Select author form number:"
    author = gen_authors(authors)

    year = gen_year # just read it

    puts "Select desired title format:"
    @title = choose(gen_forms year, title, author)
  end

  private
  # Pass in an array to list and be selected, and return the element that the
  # user selects back to the calling method. pretty sketchy way to interpret
  # the users input as a range or integer, but seems to be working for now.
  # requires you to check for an array and join it on the downside though
  def choose(opts)
    opts.each_with_index {|l, i| puts "#{i}\t#{l}" }
    printf "Your selection [0 - #{opts.length-1}]: "
    line = STDIN.gets.chomp
    meta = "opts[#{line}]"
    mout = eval meta # in theory terrible but this aint a rails app............
    if mout.is_a? (Array)
      mout.join ' '
    else
      mout
    end
  end

  # Generate different forms for author selection, enumerating the different
  # author that you want to save the file as. Split based on a comma.
  def gen_authors(aline)
    lines = aline.split(", ").map {|a| a.sub(/\d$/, '') } # delete ref number.
    if lines.is_a?(String)
      aline # return first
    else # its an array, augment w/ lname and choose
      alines = lines.map {|a| a.split.last } + lines
      choose alines
    end
  end

  # based on the collected information, generate different forms of the title.
  # perhaps at some point this could be autoselected from the command line,
  # like how the date formatting works, using symbols for different features...
  # in theory could also handle this with the eval method like above - but this
  # would probably be better as a send call or an instance_eval method :/
  def gen_forms(y, t, a)
    ad = a.downcase
    au = a.upcase
    return [
      "#{y} #{a} #{t}.pdf",
      "#{y} - #{a} - #{t}.pdf",
      "#{a}_#{y}_#{t}.pdf".gsub(" ", "_"),
      "#{au}_#{y}_#{t}.pdf".gsub(" ", "_"),
      "#{ad}_#{y}_#{t}.pdf".gsub(" ", "_"),
      "#{a} #{y} #{t}.pdf",
      "#{au} #{y} #{t}.pdf",
      "#{ad} #{y} #{t}.pdf",
    ]
  end

  # parse out a year from a string, for each line of the document until found.
  # then clean it up and return it
  def gen_year
    @fulltxt.each do |l| # find year
      lm = l.match(/(19|20)\d\d/)
      return lm[0] if !lm.nil?
    end

    Time.now.year.to_s # not matched, just return current year
  end
end
