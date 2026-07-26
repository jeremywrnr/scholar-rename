# frozen_string_literal: true

require_relative 'scholar_lookup'

# Class for choosing and displaying the information from the pdf.

class Selector
  attr_reader :title, :metadata, :content
  attr_accessor :options

  def initialize(c = "Test\nPDF\nContent", opts = { format: 0, auto: true, no_lookup: false }, lookup = nil)
    self.content = c
    @options = opts
    @lookup = lookup || ScholarLookup.new
    return unless opts[:test]

    def puts(*x) = x
  end

  def content=(str)
    @full_text = str.split("\n")
    @content = @full_text[0..14]
               .reject { |x| x.length < 2 }
               .map { |x| x[0..100] } # trim
  end

  def select_all
    title, author, year = lookup_metadata unless @options[:no_lookup]
    title, author, year = manual_metadata if title.nil?

    forms = gen_forms(year, title, author)
    @metadata = { year: year, title: title, author: author }
    @title = forms[@options[:format]]
  end

  # Query the lookup source with our best title guess, and let the user
  # accept or reject the match (--auto always accepts, matching how #choose
  # behaves elsewhere). Returns a [title, author, year] triple, or nil if
  # there was no match or it was rejected.
  def lookup_metadata
    match = @lookup.lookup(@content.first)
    return nil unless match

    summary = "#{match[:title]} -- #{match[:author]}"
    summary += " (#{match[:year]})" if match[:year]
    summary += " [#{match[:venue]}]" if match[:venue]
    puts "Found match via #{@lookup.source_name}: #{summary}"

    if @options[:auto]
      puts '(auto-accepted)'
    else
      printf 'Use this? [Y/n]: '
      resp = $stdin.gets.to_s.strip.downcase
      return nil unless resp.empty? || resp == 'y' || resp == 'yes'
    end

    [match[:title], match[:author], match[:year] || gen_year]
  end

  # Ask the user to pick the title/author lines by hand. Returns a
  # [title, author, year] triple.
  def manual_metadata
    unless @options[:auto]
      puts 'Options:'
      @content.each_with_index { |l, i| puts "#{i}\t#{l}" }
    end
    printf 'Select title line number:' unless @options[:auto]
    title = choose(@content, print: false)

    printf 'Select author line number:' unless @options[:auto]
    authors = choose(@content, print: false)

    puts 'Select author form:' unless @options[:auto]
    author = gen_authors(authors)

    [title, author, gen_year]
  end

  # based on the collected information, generate different forms of the title.
  def gen_forms(y, t, a)
    y = sanitize_path_component(y)
    t = sanitize_path_component(t)
    a = sanitize_path_component(a)
    ad = a.downcase
    au = a.upcase
    [
      "#{y} - #{a} - #{t}.pdf",
      "#{y} #{a} #{t}.pdf",
      "#{a}_#{y}_#{t}.pdf".gsub(' ', '_'),
      "#{au}_#{y}_#{t}.pdf".gsub(' ', '_'),
      "#{ad}_#{y}_#{t}.pdf".gsub(' ', '_'),
      "#{a} #{y} #{t}.pdf",
      "#{au} #{y} #{t}.pdf",
      "#{ad} #{y} #{t}.pdf"
    ]
  end

  # Filenames are built by combining year/title/author into a single path
  # segment -- strip path separators so a "/" in a title (manually picked or
  # fetched from an external source) can't turn File.rename into a move into
  # a different (likely non-existent) directory.
  def sanitize_path_component(s)
    s.to_s.gsub(%r{[/\\]}, '-')
  end

  # Pass in an array to list and be selected, and return the element that the
  # user selects back to the calling method. this is a way to interpret
  # the users input as a range (e.g., 0..2) or an integer (1).
  def choose(list, print: true)
    raise 'List is empty.' if list.empty?

    if @options[:auto]
      line = 0
    else
      # Never print when --auto.
      if print
        list.each_with_index { |l, i| puts "#{i}\t#{l}" }
        printf "[0 - #{options.length - 1}]: "
      end
      line = $stdin.gets&.chomp || 0
    end

    meta = "list[#{line}]"
    mout = eval meta # rubocop:disable Security/Eval -- `line` is local interactive/--auto input only, never external
    mout = mout.join ' ' if mout.is_a?(Array)
    mout
  end

  # Generate different forms for author selection, enumerating the different
  # author that you want to save the file as. Split based on a comma.
  def gen_authors(aline)
    lines = aline.split(', ').map { |a| a.sub(/\d$/, '') } # delete ref number.
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
      return lm[0] unless lm.nil?
    end

    Time.now.year.to_s # not matched, just return current year
  end
end
