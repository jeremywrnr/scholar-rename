# Class for choosing and displaying the information from the pdf.
# I wonder if this could be augmented with information from google scholar
# somehow, there is probably a ruby (or at least python) api.

require 'colored'

class String
  alias_method :bow, :black_on_white
end

class Selector
  attr_reader :title
  attr_accessor :content, :options

  # https://stackoverflow.com/questions/9503554/
  def initialize(c = '', opts = {:format => 0})
    set_content(c)
    @fulltxt = c.split("\n")
    @options = opts
  end

  def set_content(str)
    @content = str.split("\n")[0..14]
      .reject {|x| x.length < 2 }
      .map {|x| x[0..100] } # trim
  end

  def select_all
    puts "Options:".bow
    @content.each_with_index {|l, i| puts "#{i}\t#{l}" }
    printf "Select title line number ".bow
    title = choose(@content, print: false)

    printf "Select author line number ".bow
    authors = choose(@content, print: false)

    puts "Select author form:".bow
    author = gen_authors(authors)

    year = gen_year # just read it

    forms = gen_forms(year, title, author)
    @title = forms[@options[:format]]

    #puts "Select desired title:".bow
    #@title = choose(forms)
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

  private
  # Pass in an array to list and be selected, and return the element that the
  # user selects back to the calling method. pretty sketchy way to interpret
  # the users input as a range or integer, but seems to be working for now.
  # requires you to check for an array and join it on the downside though
  def choose(options, print: true)
    if options.length > 0
      options.each_with_index {|l, i| puts "#{i}\t#{l}" } if print
      printf "[0 - #{options.length-1}]: ".bow
      line = STDIN.gets.chomp || 0
      meta = "options[#{line}]"
      mout = eval meta # in theory terrible but this ain't a rails app.....
      if mout.is_a? (Array)
        mout.join ' '
      else
        mout
      end
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
