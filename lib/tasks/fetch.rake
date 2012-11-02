require 'nokogiri'
require 'open-uri'

#Fetch Keskimaa
def fetch_keskimaa(restaurant,link)
  puts "Fetching #{restaurant}..."
  date = Date.today - Date.today.cwday + 1
  doc = Nokogiri::HTML(open("#{link}&date=#{date.strftime('%d.%m.%Y')}"))
  doc.xpath('//div[@id = "weekListContainer"]/div').each do |row_node|
    row_node.xpath('span[starts-with(@id, "lunch_item_")]').each do |row_node|
      price = row_node.xpath('div[@class = "price fR"]')
      price.remove
      price = price.text.gsub!(/[^0-9\. ]/i, '')
      name = row_node.text.squeeze(" ").strip

      lunch = Lunch.new
      lunch.name = name
      lunch.restaurant = restaurant
      lunch.date = date
      lunch.price = price
      lunch.link = link
      lunch.save

    end
    date = date + 1
  end
end

#Fetch Sonaatti
def fetch_sonaatti( restaurant, link )
 begin
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
  rescue
  end
end

task :fetch_all => :environment do
  Lunch.delete_all
  fetch_sonaatti("Sonaati - Hestia","http://www.sonaatti.fi/hestia/")
  fetch_sonaatti("Sonaati - Ylisto","http://www.sonaatti.fi/ylisto/")
  fetch_sonaatti("Sonaati - Aallokko","http://www.sonaatti.fi/aallokko/")
  fetch_sonaatti("Sonaati - Alvari","http://www.sonaatti.fi/alvari/")
  fetch_sonaatti("Sonaati - Cafe Libri","http://www.sonaatti.fi/cafe-libri/")
  fetch_sonaatti("Sonaati - Lozzi","http://www.sonaatti.fi/lozzi/")
  fetch_sonaatti("Sonaati - Musica","http://www.sonaatti.fi/musica/")
  fetch_sonaatti("Sonaati - Syke","http://www.sonaatti.fi/syke/")
  fetch_sonaatti("Sonaati - Piato","http://www.sonaatti.fi/piato/")
  fetch_sonaatti("Sonaati - Wilhelmiina","http://www.sonaatti.fi/wilhelmiina/")
  fetch_sonaatti("Sonaati - Kvarkki","http://www.sonaatti.fi/kvarkki/")
  fetch_sonaatti("Sonaati - Novelli","http://www.sonaatti.fi/novelli/")

  fetch_keskimaa("Trattoria Aukio","http://www.lounaskeskimaa.fi/lounas_ravintola?rid=203")
  fetch_keskimaa("Veturi","http://www.lounaskeskimaa.fi/lounas_ravintola?rid=174")
  fetch_keskimaa("Mestarin Herkku","http://www.lounaskeskimaa.fi/lounas_ravintola?rid=177")
  fetch_keskimaa("ABC Keljonkangas","http://www.lounaskeskimaa.fi/lounas_ravintola?rid=168")
  Rake::Task["fetch_antelli"].invoke
  Rake::Task["fetch_ilokivi"].invoke
  Rake::Task["fetch_harald"].invoke
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
      lunch.name = node.text.split('/').first
      lunch.restaurant = "Ilokivi"
      lunch.date = date
      lunch.price = 5.6
      lunch.link = "http://jyy.fi/ruokalistat/"
      lunch.save
    end
  end  
end

#Fetch Harald
task :fetch_harald => :environment do
  puts "Fetching Harald..."
  doc = Nokogiri::HTML(open('http://www.ravintolaharald.fi/ruoka--ja-juomalistat/lounas'))
  date = Date.today - Date.today.cwday
  doc.xpath('//table[@id = "lounaslistaTable"]/tr').each do |row_node|  
    name = row_node.xpath('td[@class = "tuote"]').text
    if(name && !name.empty?)
      price = row_node.xpath('td[@class = "hinta"]').text
      lunch = Lunch.new    
      lunch.name = name
      lunch.restaurant = "Harald"
      lunch.date = date
      price.gsub!(/[^0-9, ]/i, '')
      price.gsub!(/,/, '.')
      lunch.price = price
      lunch.link = "http://www.ravintolaharald.fi/ruoka--ja-juomalistat/lounas"
      lunch.save
    else
      date = date + 1
    end
  end
end

