#CLI Interface

require 'nokogiri'
require 'open-uri'
require 'pry'

require_relative './scraper.rb'

puts "Welcome to Book Info Scraper!"
book = Scraper.new
book.scrape

puts "Author:          #{book.author}"
puts "Title:           #{book.title}"
puts "Series:          #{book.series}"
puts "Release Date:    #{book.release_date}"
