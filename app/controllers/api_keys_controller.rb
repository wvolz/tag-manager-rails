class ApiKeysController < ApplicationController
  # lots here is from https://keygen.sh/blog/how-to-implement-api-key-authentication-in-rails-without-devise/
  # TODO is the below include needed?
  include ApiKeyAuthenticatable

  before_action :set_api_key, only: [:destroy]

  # Require API key authentication
  #prepend_before_action :authenticate_with_api_key!, only: %i[index destroy]

  def index
     @api_keys = ApiKey.order(created_at: :desc)
      #format.json { render json: current_bearer.api_keys }
  end

  # GET /api-keys/new
  def new
    @api_key = current_user.api_keys.create! token: SecureRandom.hex
  end

  # POST
  def create
    respond_to do |format|
      api_key = current_user.api_keys.create! token: SecureRandom.hex
      if api_key
        format.html { redirect_to @api_key, notice: 'Api Key was successfully created.' }
        format.json { render json: api_key, status: :created }
      else
        format.html { render :new }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_key/1
  # DELETE /api_key/1.json
  def destroy
    #api_key = current_bearer.api_keys.find(params[:id])
    #api_key.destroy
    @api_key.destroy
    respond_to do |format|
      format.html { redirect_to api_keys_url, notice: 'API Key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_key
      @api_key = ApiKey.find(params[:id])
    end

end
