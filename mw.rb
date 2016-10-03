#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'date'

class WordsOfTheDays
  attr_writer :num_days
  attr_reader :entries

  FIRST_WORD_DATE = Date.new(2006,9,1)

  def self.showdate day
    day.to_s.gsub('-', '/')
  end

  def initialize(first_date = FIRST_WORD_DATE, end_date = Date.today)
    @entries = []
    @first_date = first_date
    @end_date = end_date
  end

  def get_entries
    @end_date.downto(@first_date).each do |d|
      doc = Nokogiri::HTML(open("http://www.merriam-webster.com/word-of-the-day/" + self.class.showdate(d)))
      word = doc.css("div .wod_headword").text.gsub('"', '')
      entry = { word: word, pos: "", definitions: [] , examples: ""}
      defs = doc.css("div .d")
      defs.each do |df|
        scnt = df.css("div .scnt")
        scnt.css(".ssens").each do |s|
          entry[:definitions] << s.text.gsub(/^[ a-z]*: /, '').gsub(';', '.')
        end
      end
      entry[:examples] = doc.css("div .wod_example_sentences").text.delete("\r\n").gsub(';', '.')
      entry[:pos] = doc.css("div .wod_pos").text
      #p entry
      @entries << entry
    end
    @entries
  end


end

class Hash
  def pp
    defs = self[:definitions].map do |d|
      "<p>" + d + "</p>"
    end
    puts self[:word] + ";" + "<p><b>" + self[:pos] + "</b></p>" + defs.join + "<i>" + self[:examples] + "</i>"
  end
end

scraper = WordsOfTheDays.new  #(Date.today - 10, Date.today)
scraper.get_entries.each(&:pp)
