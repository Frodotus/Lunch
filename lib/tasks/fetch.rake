require 'nokogiri'
require 'open-uri'


#Fetch Sonaatti
def fetch_sonaatti( name, url )
  puts "Fetching #{name}..."
  doc = Nokogiri::HTML(open(url))
  today_node = doc.xpath('//div[@class = "ruuat"]').first
  today_node.xpath('p').each do |lunch_node|
    if !lunch_node.text.empty?
      lunch = Lunch.new    
      lunch.name = lunch_node.text
      lunch.restaurant = name
      lunch.date = Date.today
      lunch.link = url
      lunch.save
    end
  end
  other_nodes = doc.xpath('//div[@class = "downcont"]').first
  other_nodes.xpath('p').each_with_index do |day_node,i|
    date = Date.today + i + 1
    day_node.text.split("),").each do |lunch_node|
      lunch = Lunch.new    
      lunch.name = lunch_node
      lunch.restaurant = name
      lunch.date = date
      lunch.link = url
      lunch.save    
    end
  end
end

task :fetch_all => :environment do
  Lunch.delete_all
  fetch_sonaatti("Hestia","http://www.sonaatti.fi/hestia/")
  fetch_sonaatti("Ylisto","http://www.sonaatti.fi/ylisto/")
  fetch_sonaatti("Aallokko","http://www.sonaatti.fi/aallokko/")
  fetch_sonaatti("Alvari","http://www.sonaatti.fi/alvari/")
  fetch_sonaatti("Cafe Libri","http://www.sonaatti.fi/cafe-libri/")
  fetch_sonaatti("Lozzi","http://www.sonaatti.fi/lozzi/")
  fetch_sonaatti("Musica","http://www.sonaatti.fi/musica/")
  fetch_sonaatti("Syke","http://www.sonaatti.fi/syke/")
  fetch_sonaatti("Piato","http://www.sonaatti.fi/piato/")
  fetch_sonaatti("Wilhelmiina","http://www.sonaatti.fi/wilhelmiina/")
  fetch_sonaatti("kvarkki","http://www.sonaatti.fi/kvarkki/")
  fetch_sonaatti("Novelli","http://www.sonaatti.fi/novelli/")
  Rake::Task["fetch_antelli"].ivoke
  Rake::Task["fetch_ilokivi"].ivoke
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
      lunch = Lunch.new    
      lunch.name = node.text
      lunch.restaurant = "Ilokivi"
      lunch.date = date
      lunch.link = "http://jyy.fi/ruokalistat/"
      lunch.save
    end
  end  
end
