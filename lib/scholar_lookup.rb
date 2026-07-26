require "net/http"
require "uri"
require "json"

# Queries the Semantic Scholar Graph API to cross-reference a rough title
# guess against real paper metadata. Always returns a Hash or nil; never
# raises, so a network hiccup just means the caller falls back to its own
# heuristics.
class ScholarLookup
  ENDPOINT = "https://api.semanticscholar.org/graph/v1/paper/search"
  FIELDS = "title,authors,year,venue"
  SOURCE_NAME = "Semantic Scholar"

  def initialize(open_timeout: 3, read_timeout: 5)
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

    parse(body)
  rescue StandardError
    nil
  end

  private

  def build_uri(query)
    uri = URI(ENDPOINT)
    uri.query = URI.encode_www_form("query" => query, "fields" => FIELDS, "limit" => "1")
    uri
  end

  def fetch(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = @open_timeout
    http.read_timeout = @read_timeout

    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "scholar-rename"

    res = http.request(req)
    return nil unless res.is_a?(Net::HTTPSuccess)

    res.body
  end

  def parse(body)
    papers = JSON.parse(body)["data"]
    return nil if papers.nil? || papers.empty?

    paper = papers.first
    title = paper["title"]
    author = format_authors(paper["authors"])
    return nil if title.nil? || title.strip.empty? || author.nil?

    {
      :title => title,
      :author => author,
      :year => paper["year"] && paper["year"].to_s,
      :venue => paper["venue"],
    }
  end

  def format_authors(authors)
    return nil if authors.nil? || authors.empty?

    last_names = authors.map { |a| a["name"].to_s.split.last }.compact
    return nil if last_names.empty?

    case last_names.length
    when 1, 2
      last_names.join(" ")
    else
      "#{last_names.first} et al"
    end
  end
end
