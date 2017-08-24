#CLI Interface
require 'nokogiri'
require 'open-uri'

require_relative './scraper.rb'

puts "Welcome to Book Info Scraper!"
book = Scraper.new
book.scrape

puts "Title:".ljust(22) << "#{book.title}"
puts "Author:".ljust(22) << "#{book.author}"
puts "Series:".ljust(22) << "#{book.series}"
if book.release_date.size > 0
  puts "Release Date:".ljust(22) << "#{book.release_date}"
else
  puts "Release Date:".ljust(22) << "No date yet"
end
