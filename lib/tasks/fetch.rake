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
  today_node = doc.xpath('//div[@class = "ruuat"]').first
  today_node.xpath('p').each do |lunch_node|
    if !lunch_node.text.empty?
      puts "#{lunch_node.text}"
      lunch = Lunch.new    
      lunch.name = lunch_node.text
      lunch.restaurant = "Hestia"
      lunch.date = Date.today
      lunch.link = "http://www.sonaatti.fi/hestia/"
      lunch.save
    end
  end
  other_nodes = doc.xpath('//div[@class = "downcont"]').first
  other_nodes.xpath('p').each_with_index do |day_node,i|
    date = Date.today + i + 1
    day_node.text.split("),").each do |lunch_node|
      lunch = Lunch.new    
      lunch.name = lunch_node
      lunch.restaurant = "Hestia"
      lunch.date = date
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
  doc.xpath('//table[@class = "lunchTable2"]').each_with_index do |date_node,i|
    date = Date.today - Date.today.cwday + i + 1
    date_node.xpath('tbody/tr/td[@class = "tdc"]').each do |lunch_node|
      lunch = Lunch.new    
      lunch.name = lunch_node.text
      lunch.restaurant = "Antelli"
      lunch.date = date
      lunch.link = "http://www.antellcatering.fi/docs/lunch.php?Technopolis%20Jyv%E4skyl%E4"
      lunch.save
    end
  end
end

#Fetch Ilokivi
task :fetch_ilokivi => :environment do
  puts "Fetching Ilokivi..."
  doc = Nokogiri::HTML(open('http://jyy.fi/ruokalistat/'))
  doc.xpath('//ul[@class = "food-list"]').each_with_index do |date_node,i|
    date = Date.today - Date.today.cwday + i + 1
    date_node.xpath('li').each do |node|
      puts "#{node.text} #{date}"
      lunch = Lunch.new    
      lunch.name = node.text
      lunch.restaurant = "Ilokivi"
      lunch.date = date
      lunch.link = "http://jyy.fi/ruokalistat/"
      lunch.save
    end
  end  
end
