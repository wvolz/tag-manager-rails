class TagscansController < ApplicationController
  before_action :set_tagscan, only: [:show, :edit, :update, :destroy]

  # GET /tagscans
  # GET /tagscans.json
  def index
    @tagscans = Tagscan.all
  end

  # GET /tagscans/1
  # GET /tagscans/1.json
  def show
  end

  # GET /tagscans/new
  def new
    @tagscan = Tagscan.new
  end

  # GET /tagscans/1/edit
  def edit
  end

  # POST /tagscans
  # POST /tagscans.json
  def create
    @tagscan = Tagscan.new(tagscan_params)

    respond_to do |format|
      if @tagscan.save
        format.html { redirect_to @tagscan, notice: 'Tagscan was successfully created.' }
        format.json { render :show, status: :created, location: @tagscan }
      else
        format.html { render :new }
        format.json { render json: @tagscan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tagscans/1
  # PATCH/PUT /tagscans/1.json
  def update
    respond_to do |format|
      if @tagscan.update(tagscan_params)
        format.html { redirect_to @tagscan, notice: 'Tagscan was successfully updated.' }
        format.json { render :show, status: :ok, location: @tagscan }
      else
        format.html { render :edit }
        format.json { render json: @tagscan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tagscans/1
  # DELETE /tagscans/1.json
  def destroy
    @tagscan.destroy
    respond_to do |format|
      format.html { redirect_to tagscans_url, notice: 'Tagscan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tagscan
      @tagscan = Tagscan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tagscan_params
      params.require(:tagscan).permit(:tag_id, :antenna, :rssi)
    end
end
