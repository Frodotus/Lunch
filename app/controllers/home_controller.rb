class HomeController < ApplicationController
  def index
    @matches = []
    @others = []
    @lunches = Lunch.all( :conditions => {
      :date => Date.today
    })
    @lunches.each {|lunch|
      if lunch.name.include? "Kebab"
        @matches << lunch
      else
        @others << lunch
      end
    }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lunches }
    end
  end
end
