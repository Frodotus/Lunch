require 'nokogiri'
require 'open-uri'
task :fetch => :environment do
  Lunch.delete_all
  #Fetch hestia
  doc = Nokogiri::HTML(open('http://www.sonaatti.fi/hestia/'))
  foods = doc.xpath('//div[@class = "ruuat"]').first
  foods.xpath('p').each do |node|
    lunch = Lunch.new    
    lunch.name = node.text
    lunch.save
  end
  
  #Fetch Antelli
  doc = Nokogiri::HTML(open('http://www.antellcatering.fi/docs/lunch.php?Technopolis%20Jyv%E4skyl%E4'))
  src = doc.xpath('//frame[@name = "lunchmain"]').first['src']
  doc = Nokogiri::HTML(open("http://www.antellcatering.fi/docs/#{src}"))
  doc.xpath('//td[@class = "tdc"]').each do |node|
     puts node.text
    lunch = Lunch.new    
    lunch.name = node.text
    lunch.save
  end

end

task :fetch_ilokivi => :environment do
  #Fetch Ilokivi
  doc = Nokogiri::HTML(open('http://jyy.fi/ruokalistat/'))
#  src = doc.xpath('//frame[@name = "lunchmain"]').first['src']
#  doc = Nokogiri::HTML(open("http://www.antellcatering.fi/docs/#{src}"))
#  doc.xpath('//td[@class = "tdc"]').each do |node|
#     puts node.text
#    lunch = Lunch.new    
#    lunch.name = node.text
#    lunch.save
#  end  
end
