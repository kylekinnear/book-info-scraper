require 'nokogiri'
require 'open-uri'

class Scraper
  attr_accessor :author, :title, :series, :release_date, :average, :ratings, :blurb

  def call
    puts "Welcome to Book Info Scraper!"
    scrape

    puts "Title:".ljust(22) << "#{@title}"
    puts "Author:".ljust(22) << "#{@author}"
    puts "Series:".ljust(22) << "#{@series}"
    if @release_date.size > 0
      puts "Release Date:".ljust(22) << "#{@release_date}"
    else
      puts "Release Date:".ljust(22) << "No date yet"
    end
    if @average.size > 0
      puts "Rating (#):".ljust(22) << "#{@average} (#{@ratings})"
    else
      puts "Ratings:".ljust(22) << "No ratings yet"
    end
    if @blurb.size > 0
      puts "Blurb:"
      puts "#{wrap_blurb}"
    else
      puts "Blurb:"
      puts "No blurb yet"
    end
  end


  def scrape
    puts "Enter your search term (usually combination of author and title)"
    input = gets.strip #gets input line
    if input.size > 0 #checks valid input
      if input.upcase == "quit".upcase
        return
      end
      puts "Checking now!"
      input.gsub!(/(\W)+/, "+") #formats input as valid search string
      search_page = Nokogiri::HTML(open("https://www.goodreads.com/search?q=#{input}&search_type=books")) #interpolates input to search url and pulls page with nokogiri
      if search_page.css("table a").size != 0
        item_page = Nokogiri::HTML(open("https://goodreads.com/#{search_page.css("table a").attribute("href").value}").read)
      else
        raise NoBook
      end
      @author = item_page.css("div#bookAuthors.stacked span :not(.greyText) :not(.smallText)").text
      @title = item_page.css("h1#bookTitle.bookTitle").text.reverse.strip.reverse.lines.first.chomp #provides title
      @series = ((item_page.css("h1#bookTitle.bookTitle :first-child").text.strip).sub "(", "").sub ")", "" #provides series
      @release_date = item_page.css("div#details .row").text.split(/\n+/)[2].sub /\A\s+/, "" #provides the release date
      @average = item_page.css("span.average").text
      @ratings = item_page.css("span.votes.value-title").text.strip
      @blurb = item_page.xpath('//span[starts-with(@id, "freeText")]')[1].text.gsub(/\s+/, " ")
    end
  end

  def wrap_blurb(width=78)
    lines = []
    line = ""
    @blurb.split(/\s+/).each do |word|
  #    if /[.?!]\S/.match(word) != nil
  #      word.gsub(".", ".\n")
  #      word.gsub("?", "?\n")
  #      word.gsub("!", "!\n")
  #    end
      if line.size + word.size >= width
        lines << line
        line = word
      elsif line.empty?
        line = word
      else
        line << " " << word
      end
    end
    lines << line if line
    return (lines.join "\n")#.gsub(/[.!?]\S/){|match| "#{match[0]}\n#{match[1]}"}
  end

  class NoBook < StandardError
    def message
      "A Goodreads page for this book does not yet exist. Check back in a while!"
    end
  end

end
