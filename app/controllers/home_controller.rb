class HomeController < ApplicationController
  def index
    @matches = []
    @others = []
    if user_signed_in?
      names = current_user.preferences.split('|')
      names.map! { |x| "%#{x}%" }
      @matches = Lunch.where(:date => Date.today).where{name.like_any names}
    else
      @matches = Lunch.where(:date => Date.today)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lunches }
    end
  end
end
