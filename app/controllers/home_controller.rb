class HomeController < ApplicationController
  def index
    @matches = Lunch.where(:date => Date.today)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lunches }
    end
  end
end
