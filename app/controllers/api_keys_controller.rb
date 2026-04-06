class ApiKeysController < ApplicationController
  # lots here is from https://keygen.sh/blog/how-to-implement-api-key-authentication-in-rails-without-devise/
  # TODO is the below include needed?
  include ApiKeyAuthenticatable

  before_action :set_api_key, only: [ :show, :edit, :update, :destroy ]

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
    # pre-fill bearer if they clicked from a reader profile
    if params["bearer_type"] && params["bearer_id"]
      @api_key.bearer_string = "#{params["bearer_type"]}_#{params["bearer_id"]}"
    else
      @api_key.bearer_string = "User_#{current_user.id}"
    end
  end

  # GET /api_keys/1/edit
  def edit
  end

  # POST
  def create
    respond_to do |format|
      @api_key = ApiKey.new(api_key_params)

      # Security check: only allow creating keys for oneself or a valid Reader
      unless @api_key.bearer_string.start_with?("Reader_") || @api_key.bearer_string == "User_#{current_user.id}"
        @api_key.errors.add(:base, "Not authorized to create keys for this user")
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @api_key.errors, status: :unprocessable_entity }
        return
      end

      if @api_key.save
        # Pass token via dedicated flash key — show view renders a secure one-time reveal card
        flash[:api_key_token] = @api_key.token
        format.html { redirect_to @api_key }
        format.json { render json: { id: @api_key.id, token: @api_key.token }, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
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
        format.html { render :edit, status: :unprocessable_entity }
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
    params.require(:api_key).permit(:bearer_string, :comment) # Token is automatically generated
  end
end
