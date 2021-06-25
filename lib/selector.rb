# Class for choosing and displaying the information from the pdf.
# I wonder if this could be augmented with information from google scholar
# somehow, there is probably a ruby (or at least python) api.

class Selector
  attr_reader :title, :metadata, :content
  attr_accessor :options

  def initialize(c = "Test\nPDF\nContent", opts = { :format => 0, :auto => true })
    set_content(c)
    @options = opts
    if opts[:test]
      def puts(*x) x; end
    end
  end

  def set_content(str)
    @full_text = str.split("\n")
    @content = @full_text[0..14]
      .reject { |x| x.length < 2 }
      .map { |x| x[0..100] } # trim
  end

  def select_all
    if !@options[:auto]
      puts "Options:"
      @content.each_with_index { |l, i| puts "#{i}\t#{l}" }
    end
    printf "Select title line number:" unless @options[:auto]
    title = choose(@content, print: false)

    printf "Select author line number:" unless @options[:auto]
    authors = choose(@content, print: false)

    puts "Select author form:" unless @options[:auto]
    author = gen_authors(authors)

    # Automatically match.
    year = gen_year
    
    forms = gen_forms(year, title, author)
    @metadata = {:year => year, :title => title, :author => author}
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
  def choose(list, print: true)
    raise "List is empty." if list.empty?

    if @options[:auto]
      line = 0
    else
      # Never print when --auto.
      if print
        list.each_with_index { |l, i| puts "#{i}\t#{l}" }
        printf "[0 - #{options.length - 1}]: "
      end
      line = STDIN.gets.chomp || 0
    end

    meta = "list[#{line}]"
    mout = eval meta
    mout = mout.join " " if mout.is_a? (Array)
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
    @full_text.each do |l| # find year
      lm = l.match(/(19|20)\d\d/)
      return lm[0] if !lm.nil?
    end

    Time.now.year.to_s # not matched, just return current year
  end
end
