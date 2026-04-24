class ReadersController < ApplicationController
  before_action :set_authorizer_app
  before_action :set_reader, only: %i[show edit update destroy]

  # GET /readers or /readers.json
  def index
    @readers = @authorizer_app.readers.includes(:reader_antennas).order(:name)
  end

  # GET /readers/1 or /readers/1.json
  def show
  end

  # GET /readers/new
  def new
    @reader = @authorizer_app.readers.new
    build_reader_antenna_row
  end

  # GET /readers/1/edit
  def edit
    build_reader_antenna_row
  end

  # POST /readers or /readers.json
  def create
    @reader = @authorizer_app.readers.new(reader_params)

    respond_to do |format|
      if @reader.save
        format.html { redirect_to reader_url(@reader), notice: "Reader was successfully created." }
        format.json { render :show, status: :created, location: @reader }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reader.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /readers/1 or /readers/1.json
  def update
    respond_to do |format|
      if @reader.update(reader_params)
        format.html { redirect_to reader_url(@reader), notice: "Reader was successfully updated." }
        format.json { render :show, status: :ok, location: @reader }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reader.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /readers/1 or /readers/1.json
  def destroy
    @reader.destroy

    respond_to do |format|
      format.html { redirect_to readers_url, notice: "Reader was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_reader
    @reader = @authorizer_app.readers.find(params[:id])
  end

  def set_authorizer_app
    @authorizer_app = current_authorizer_app
    return if @authorizer_app.present?

    redirect_to root_path, alert: "No authorizer app is configured yet."
  end

  # Only allow a list of trusted parameters through.
  def reader_params
    params.require(:reader).permit(
      :name,
      :location,
      :mac_address,
      :reader_name,
      :hostname,
      reader_antennas_attributes: [ :id, :antenna, :authorization_id, :_destroy ]
    )
  end

  def build_reader_antenna_row
    return if @reader.reader_antennas.any?(&:new_record?)

    @reader.reader_antennas.build
  end
end
