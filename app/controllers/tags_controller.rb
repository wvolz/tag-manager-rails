class TagsController < ApplicationController
  include ApiKeyAuthenticatable

  before_action :set_tag, only: [ :show, :edit, :update, :destroy ]
  before_action :set_tag_by_epc, only: [ :authorize ]
  skip_before_action :require_login, only: [ :authorize ]
  prepend_before_action :authenticate_with_api_key_json!, only: [ :authorize ]
  helper_method :sort_column, :sort_direction

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.order({ sort_column => sort_direction })
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # GET /tags/:epc/authorize
  def authorize
    if params[:mac].present? || params[:antenna].present?
      authorize_by_mac_and_antenna
    else
      authorize_by_legacy_param
    end
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: "Tag was successfully created." }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: "Tag was successfully updated." }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: "Tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
  end

  def set_tag_by_epc
    @tag = Tag.find_by(epc: params[:id])
    unless @tag
      raise ActiveRecord::RecordNotFound
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(:epc, :tid, :user_memory, :pc, :description, :tag_type_id, authorization_ids: [])
  end

  def sort_column
    Tag.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def authorize_by_mac_and_antenna
    unless params[:mac].present? && params[:antenna].present?
      render json: { error: "mac and antenna are required" }, status: :bad_request
      return
    end

    unless current_bearer.is_a?(AuthorizerApp)
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    antenna_value = Integer(params[:antenna], exception: false)
    if antenna_value.nil?
      render json: { error: "antenna must be an integer" }, status: :bad_request
      return
    end

    normalized_mac = Reader.normalize_mac(params[:mac])
    reader = current_bearer.readers.find_by(mac_address: normalized_mac)
    unless reader
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    reader_antenna = reader.reader_antennas.find_by(antenna: antenna_value)
    if reader_antenna.nil? || reader_antenna.authorization_id.nil?
      @auth_response = "record_only"
      @db_result = nil
      return
    end

    @db_result = Authorization.find_by(id: reader_antenna.authorization_id)
    @auth_response = @tag.authorizations.exists?(id: reader_antenna.authorization_id) ? "authorized" : "unauthorized"
  end

  def authorize_by_legacy_param
    @auth_response = "unauthorized"
    @db_result = nil
    if @tag.authorizations.exists?(id: params[:a])
      @db_result = @tag.authorizations.find_by(id: params[:a])
      @auth_response = "authorized" if @db_result
    end
  end
end
