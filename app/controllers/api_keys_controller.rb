class ApiKeysController < ApplicationController
  # lots here is from https://keygen.sh/blog/how-to-implement-api-key-authentication-in-rails-without-devise/
  # TODO is the below include needed?
  include ApiKeyAuthenticatable

  before_action :set_api_key, only: [:show, :edit, :update, :destroy]

  # Require API key authentication
  # prepend_before_action :authenticate_with_api_key!, only: %i[index destroy]

  def index
    @api_keys = ApiKey.order(created_at: :desc)
  end

  # GET /api_keys/1
  # GET /api_keys/1.json
  def show
  end

  # GET /api_keys/new
  def new
    @api_key = ApiKey.new
    @api_key.token = SecureRandom.hex
    @api_key.bearer_id = params["bearer_id"]
    @api_key.bearer_type = params["bearer_type"]
  end

  # GET /api_keys/1/edit
  def edit
  end

  # POST
  def create
    respond_to do |format|
      @api_key = ApiKey.new(api_key_params)
      if @api_key.save
        format.html { redirect_to @api_key, notice: "Api Key was successfully created." }
        format.json { render json: api_key, status: :created }
      else
        format.html { render :new }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api_keys/1
  # PATCH/PUT /api_keys/1.json
  def update
    respond_to do |format|
      if @api_key.update(api_key_params)
        format.html { redirect_to @api_key, notice: "Api Key was successfully updated." }
        format.json { render :show, status: :ok, location: @api_key }
      else
        format.html { render :edit }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_keys/1
  # DELETE /api_keys/1.json
  def destroy
    @api_key.destroy
    respond_to do |format|
      format.html { redirect_to api_keys_url, notice: "API Key was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_api_key
    @api_key = ApiKey.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def api_key_params
    params.require(:api_key).permit(:bearer_id, :bearer_type, :comment, :token)
  end
end
