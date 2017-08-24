require 'nokogiri'
require 'open-uri'

class Scraper
  attr_accessor :author, :title, :series, :release_date, :scrape_hash

  def scrape
    puts "Enter your search term (usually combination of author and title)"
    input = gets.strip #gets input line
    if input.size > 0 #checks valid input
      puts "Checking now!"
      input.gsub!(/(\W)+/, "+") #formats input as valid search string
      search_page = Nokogiri::HTML(open("https://www.goodreads.com/search?q=#{input}&search_type=books")) #interpolates input to search url and pulls page with nokogiri
      if search_page.css("table a").size != 0
        item_page = Nokogiri::HTML(open("https://goodreads.com/#{search_page.css("table a").attribute("href").value}"))
      else
        raise NoBook
      end
      @author = item_page.css("div#bookAuthors.stacked span :not(.greyText) :not(.smallText)").text
      @title = item_page.css("h1#bookTitle.bookTitle").text.reverse.strip.reverse.lines.first.chomp #provides title
      @series = ((item_page.css("h1#bookTitle.bookTitle :first-child").text.strip).sub "(", "").sub ")", "" #provides series
      @release_date = item_page.css("div#details .row").text.split(/\n+/)[2].sub /\A\s+/, "" #provides the release date
    end
  end

  class NoBook < StandardError
    def message
      "A Goodreads page for this book does not yet exist. Check back in a while!"
    end
  end

end
