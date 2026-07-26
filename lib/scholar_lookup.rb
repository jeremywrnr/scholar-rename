# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

# Queries the Semantic Scholar Graph API to cross-reference a rough title
# guess against real paper metadata. Always returns a Hash or nil; never
# raises, so a network hiccup just means the caller falls back to its own
# heuristics.
class ScholarLookup
  ENDPOINT = 'https://api.semanticscholar.org/graph/v1/paper/search'
  FIELDS = 'title,authors,year,venue'
  SOURCE_NAME = 'Semantic Scholar'

  # Exceptions expected from a flaky network/API, silently treated as "no
  # match". Anything else (e.g. a response-shape change breaking #parse) is
  # still caught so a rename can never crash, but is reported via warn so the
  # regression isn't invisible.
  EXPECTED_ERRORS = [
    SocketError,
    Timeout::Error,
    SystemCallError,
    OpenSSL::SSL::SSLError,
    Net::ProtocolError,
    JSON::ParserError
  ].freeze

  # A match only counts if at least half of the query's words also appear in
  # the returned title -- guards against a short/generic query (e.g. a running
  # header) fuzzy-matching an unrelated paper.
  MIN_WORD_OVERLAP = 0.5

  def initialize(open_timeout: 2, read_timeout: 3)
    @open_timeout = open_timeout
    @read_timeout = read_timeout
  end

  def source_name
    SOURCE_NAME
  end

  def lookup(query)
    return nil if query.nil? || query.strip.length < 4

    body = fetch(build_uri(query.strip))
    return nil if body.nil?

    match = parse(body)
    return nil unless match && plausible_match?(query, match[:title])

    match
  rescue *EXPECTED_ERRORS
    nil
  rescue StandardError => e
    warn "scholar-rename: unexpected lookup error (#{e.class}): #{e.message}"
    nil
  end

  private

  def plausible_match?(query, title)
    query_words = normalize_words(query)
    title_words = normalize_words(title)
    return false if query_words.empty? || title_words.empty?

    overlap = (query_words & title_words).length
    overlap.to_f / query_words.length >= MIN_WORD_OVERLAP
  end

  def normalize_words(str)
    str.downcase.gsub(/[^a-z0-9\s]/, '').split
  end

  def build_uri(query)
    uri = URI(ENDPOINT)
    uri.query = URI.encode_www_form('query' => query, 'fields' => FIELDS, 'limit' => '1')
    uri
  end

  def fetch(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = @open_timeout
    http.read_timeout = @read_timeout

    req = Net::HTTP::Get.new(uri)
    req['User-Agent'] = 'scholar-rename'

    res = http.request(req)
    return nil unless res.is_a?(Net::HTTPSuccess)

    res.body
  end

  def parse(body)
    papers = JSON.parse(body)['data']
    return nil if papers.nil? || papers.empty?

    paper = papers.first
    title = paper['title']
    author = format_authors(paper['authors'])
    return nil if title.nil? || title.strip.empty? || author.nil?

    {
      title: title,
      author: author,
      year: paper['year']&.to_s,
      venue: paper['venue']
    }
  end

  def format_authors(authors)
    return nil if authors.nil? || authors.empty?

    last_names = authors.map { |a| a['name'].to_s.split.last }.compact
    return nil if last_names.empty?

    case last_names.length
    when 1, 2
      last_names.join(' ')
    else
      "#{last_names.first} et al"
    end
  end
end
