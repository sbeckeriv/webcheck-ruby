require 'nokogiri'
require 'uri'

# Locates all of the hyperlinks in the body of an HTML document
class Linkfinder
  
  # Retrieve a list of all the links from the specified HTML
  # * html - The source to parse
  # returns: All found links, raw, as an Array
  def getLinks(html)
    doc = Nokogiri::HTML(html)
    result = Array.new
    doc.css('a').each do |link|
      result << link[:href]
    end
    result
  end

  # convert relative URLs(strings) to absolute URLs
  # (URIs), filling in information from the base URI
  # as needed
  #
  # * urls - array of string urls
  # * baseURI - the URI to use as the base for relative
  #   resolution
  # return: array of absolute URIs
  def convertToAbsolute(urls,baseURI)
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

  def inDomain?(uri,domainURI)
      uri.host == domainURI.host
  end
end