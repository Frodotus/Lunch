class HomeController < ApplicationController
  def index
    @matches = []
    @others = []
    @lunches = Lunch.all( 
      :conditions => { :date => Date.today },
      :order => 'name'
    )
    @lunches.each {|lunch|
      if !!lunch.name.match(/(Riista|Porsaanleike)/im)
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
