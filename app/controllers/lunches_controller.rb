class LunchesController < ApplicationController
  # GET /lunches
  # GET /lunches.json
  def index
    @matches = []
    @others = []
    @lunches = Lunch.order("date")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lunches }
    end
  end

  def preferred
    @matches = []
    if user_signed_in? && current_user.preferences
      names = current_user.preferences.split('|')
      names.map! { |x| "%#{x}%" }
      @matches = Lunch.where(:date => Date.today).where{name.like_any names}
    else
      @matches = []
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @matches }
    end
  end

  # GET /lunches/1
  # GET /lunches/1.json
  def show
    @lunch = Lunch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lunch }
    end
  end

  # GET /lunches/new
  # GET /lunches/new.json
  def new
    @lunch = Lunch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lunch }
    end
  end

  # GET /lunches/1/edit
  def edit
    @lunch = Lunch.find(params[:id])
  end

  # POST /lunches
  # POST /lunches.json
  def create
    @lunch = Lunch.new(params[:lunch])

    respond_to do |format|
      if @lunch.save
        format.html { redirect_to @lunch, notice: 'Lunch was successfully created.' }
        format.json { render json: @lunch, status: :created, location: @lunch }
      else
        format.html { render action: "new" }
        format.json { render json: @lunch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lunches/1
  # PUT /lunches/1.json
  def update
    @lunch = Lunch.find(params[:id])

    respond_to do |format|
      if @lunch.update_attributes(params[:lunch])
        format.html { redirect_to @lunch, notice: 'Lunch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lunch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lunches/1
  # DELETE /lunches/1.json
  def destroy
    @lunch = Lunch.find(params[:id])
    @lunch.destroy

    respond_to do |format|
      format.html { redirect_to lunches_url }
      format.json { head :no_content }
    end
  end
end
