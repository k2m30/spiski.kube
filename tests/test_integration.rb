require 'nokogiri'
require 'open-uri'
require "minitest/autorun"

class TestWebPage < Minitest::Test
  def setup
  end

  def test_open_main_page
    page = Nokogiri::HTML(URI.open("http://spiski.live/"))
    assert(page.css("#count").size > 0)
  end

  def test_search
    page = Nokogiri::HTML(URI.open(URI.escape("http://spiski.live/?q=Чирич")))
    assert(page.css(".search-result").size > 0)
  end

end