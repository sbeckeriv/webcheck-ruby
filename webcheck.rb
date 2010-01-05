require 'net/http'
require 'uri' 
require 'nokogiri'

class Webcheck

  # Retrieve a list of all the links from the specified HTML
  # * html - The source to parse
  # returns: All found links, raw, as an Array
  def self.getLinks(html)
    doc = Nokogiri::HTML(html)
    result = Array.new
    doc.css('a').each do |link|
      result << link[:href]
    end
    result
  end

  # Open a page and extract URLs from the page
  # * uri - The URL to open (as a URI)
  # returns:
  # * code - String form of the result code
  # * links - raw links retrieved from the page (may be
  #   nil if the page suffered an error
  def self.getLinksFromPage(uri)
    req = Net::HTTP::start(uri.host,uri.port) {|http|
      http.get(uri.path)
    }
    if req.code == "404"
      return req.code
    end	
    return req.code,self.getLinks(req.body)
  end

  # convert relative URLs(strings) to absolute URLs
  # (URIs), filling in information from the base URI
  # as needed
  #
  # * urls - array of string urls
  # * baseURI - the URI to use as the base for relative
  #   resolution
  # return: array of absolute URIs
  def self.convertToAbsolute(urls,baseURI)
    result=[]
    urls.each {|url|
      newURI=URI(url)
      if newURI.relative?
        if url[0]=="/"[0]
	  newURI=URI("http://" + baseURI.host + url)
        else
	  newURI=baseURI + newURI
        end
      end
      result << newURI
    }
    return result
  end

  attr_reader :crawled,:toCrawl,:pages404,:pages200,:unhandledCodes
  def initialize(startURI)
    @crawled = {}
    @toCrawl = []
    @pages404 = []
    @pages200 = []
    @unhandledCodes = []
    @startURI=URI(startURI)
  end
  
  def getCrawled
	@crawled
  end
  
  def getToCrawl
	@toCrawl
  end
  
  def getPages404
	@pages404
  end
  
  def getPages200
	@pages200
  end


  # crawl a single page, updating the internal notions 
  # of which pages 404 and which pages
  # have not yet been seen
  #
  # * uri - The URI to crawl
  def crawlOne(uri)
    @crawled[uri]=true
    code,links = Webcheck::getLinksFromPage(uri)
    
    if code=="404"
      @pages404 << uri
    elsif code=="200"
      @pages200 << uri
      links=Webcheck::convertToAbsolute(links,uri)
      links.each {|link|
        if @crawled[link] == nil
          @toCrawl << link
        end
      }
    else
      @unhandledCodes << [uri,code]
    end
  end
end