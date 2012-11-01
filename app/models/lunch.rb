class Lunch < ActiveRecord::Base
  attr_accessible :name, :price, :date, :restaurant, :link
end
