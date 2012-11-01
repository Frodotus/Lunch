class HomeController < ApplicationController
  def index
    @matches = []
    @others = []
    @lunches = Lunch.all( 
      :conditions => { :date => Date.today },
      :order => 'name'
    )
    if user_signed_in?

      @lunches.each {|lunch|
        expr = current_user.preferences
        if !!lunch.name.match(/(#{expr})/im)
          @matches << lunch
        else
          @others << lunch
        end
      }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lunches }
    end
  end
end
