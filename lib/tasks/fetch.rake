require 'nokogiri'
require 'open-uri'


#Fetch Sonaatti
def fetch_sonaatti( restaurant, link )
  puts "Fetching #{restaurant}..."
  doc = Nokogiri::HTML(open(link))
  today_node = doc.xpath('//div[@class = "ruuat"]').first
  lunches = []
  today_node.xpath('p').each do |lunch_node|
    lunches << {:name=>lunch_node.text,:date=>Date.today,:restaurant=>restaurant,:link=>link}
  end
  today_price_node = doc.xpath('//div[@class = "hinnat"]').first
  today_price_node.inner_html.split('<br>').each_with_index do |price,i|
    price = price.split("/").last
    if price
      price.gsub!(/[^0-9, ]/i, '')
      price.gsub!(/,/, '.')
      lunches[i][:price] = price
    end
  end

  other_nodes = doc.xpath('//div[@class = "downcont"]').first
  other_nodes.xpath('p').each_with_index do |day_node,i|
    date = Date.today + i + 1
    day_node.text.split("),").each do |lunch_node|
      lunch = lunch_node.split(' (')
      price = lunch.last.split('/').last
      price.gsub!(/[^0-9, ]/i, '')
      price.gsub!(/,/, '.')
      lunches << {:name=>lunch[0], :price=>price, :date=>date,:restaurant=>restaurant,:link=>link}      
    end
  end

  lunches.each do |l|
    if l[:name] && !l[:name].empty?
      lunch = Lunch.create(l)    
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
  Rake::Task["fetch_antelli"].invoke
  Rake::Task["fetch_ilokivi"].invoke
end
  
task :fetch_hestia => :environment do
  fetch_sonaatti("Hestia","http://www.sonaatti.fi/hestia/")
end

#Fetch Antelli
task :fetch_antelli => :environment do
  puts "Fetching Antelli..."
  doc = Nokogiri::HTML(open('http://www.antellcatering.fi/docs/lunch.php?Technopolis%20Jyv%E4skyl%E4'))
  src = doc.xpath('//frame[@name = "lunchmain"]').first['src']
  doc = Nokogiri::HTML(open("http://www.antellcatering.fi/docs/#{src}"))
  doc.xpath('//table[@class = "lunchTable2"]').each_with_index do |date_node,i|
    date = Date.today - Date.today.cwday + i + 1
    date_node.xpath('tbody/tr').each do |lunch_node|      
      lunch = Lunch.new    
      lunch.name = lunch_node.xpath('td[@class = "tdc"]').text
      lunch.restaurant = "Antelli"
      lunch.date = date
      price = lunch_node.xpath('td[@class = "tdd"]').text
      price.gsub!(/[^0-9, ]/i, '')
      price.gsub!(/,/, '.')
      lunch.price = price
      lunch.link = "http://www.antellcatering.fi/docs/lunch.php?Technopolis%20Jyv%E4skyl%E4"
      lunch.save
      p lunch
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
      lunch.price = 5.6
      lunch.link = "http://jyy.fi/ruokalistat/"
      lunch.save
    end
  end  
end
