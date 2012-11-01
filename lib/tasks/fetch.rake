require 'nokogiri'
require 'open-uri'

task :fetch_all => :environment do
  Lunch.delete_all
  Rake::Task["fetch_hestia"].invoke
  Rake::Task["fetch_antelli"].invoke
  Rake::Task["fetch_ilokivi"].invoke
end

#Fetch Hestia
task :fetch_hestia => :environment do
  puts "Fetching Hestia..."
  doc = Nokogiri::HTML(open('http://www.sonaatti.fi/hestia/'))
  foods = doc.xpath('//div[@class = "ruuat"]').first
  foods.xpath('p').each do |node|
    if !node.text.empty?
      lunch = Lunch.new    
      lunch.name = node.text
      lunch.restaurant = "Hestia"
      lunch.date = Date.today
      lunch.link = "http://www.sonaatti.fi/hestia/"
      lunch.save
    end
  end
end
  
#Fetch Antelli
task :fetch_antelli => :environment do
  puts "Fetching Antelli..."
  doc = Nokogiri::HTML(open('http://www.antellcatering.fi/docs/lunch.php?Technopolis%20Jyv%E4skyl%E4'))
  src = doc.xpath('//frame[@name = "lunchmain"]').first['src']
  doc = Nokogiri::HTML(open("http://www.antellcatering.fi/docs/#{src}"))
  foods = doc.xpath('//table[@class = "lunchTable2"]').first
  foods.xpath('tbody/tr/td[@class = "tdc"]').each do |node|
    lunch = Lunch.new    
    lunch.name = node.text
    lunch.restaurant = "Antelli"
    lunch.date = Date.today
    lunch.link = "http://www.antellcatering.fi/docs/lunch.php?Technopolis%20Jyv%E4skyl%E4"
    lunch.save
  end
end

#Fetch Ilokivi
task :fetch_ilokivi => :environment do
  puts "Fetching Ilokivi..."
  doc = Nokogiri::HTML(open('http://jyy.fi/ruokalistat/'))
  foods = doc.xpath('//ul[@class = "food-list"]').first
  foods.xpath('li').each do |node|
#     puts node.text
    lunch = Lunch.new    
    lunch.name = node.text
    lunch.restaurant = "Ilokivi"
    lunch.date = Date.today
    lunch.link = "http://jyy.fi/ruokalistat/"
    lunch.save
  end  
end
