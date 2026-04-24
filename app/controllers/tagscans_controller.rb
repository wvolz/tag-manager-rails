class TagscansController < ApplicationController
  include ApiKeyAuthenticatable

  before_action :set_tagscan, only: [ :show, :edit, :update, :destroy ]
  skip_before_action :verify_authenticity_token, only: [ :upload_photo ]
  skip_before_action :require_login, only: [ :create, :upload_photo ]
  prepend_before_action :authenticate_with_api_key_json!, only: [ :create ]
  prepend_before_action :authenticate_with_api_key!, only: [ :upload_photo ]

  # GET /tagscans
  # GET /tagscans.json
  def index
    @pagy, @tagscans = pagy(Tagscan.order(received_at: :desc))
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
    attributes = tagscan_params.to_h.symbolize_keys
    mac = Reader.normalize_mac(attributes.delete(:mac) || params[:mac])
    source_ip = attributes.delete(:source_ip) || params[:source_ip]
    reader_name = attributes.delete(:reader_name)
    hostname = attributes.delete(:hostname)

    resolved_reader = resolve_reader_for_mac(mac)
    return if performed?

    @tagscan = Tagscan.new(attributes)
    @tagscan.reader = resolved_reader if resolved_reader

    respond_to do |format|
      if @tagscan.save
        update_reader_activity(resolved_reader, source_ip:, reader_name:, hostname:) if resolved_reader
        format.html { redirect_to @tagscan, notice: "Tagscan was successfully created." }
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
        format.html { redirect_to @tagscan, notice: "Tagscan was successfully updated." }
        format.json { render :show, status: :ok, location: @tagscan }
      else
        format.html { render :edit }
        format.json { render json: @tagscan.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /tagscans/:event_id/photo
  def upload_photo
    tagscan = Tagscan.find_by!(event_id: params[:event_id])

    if tagscan.image.attached?
      render json: { error: "Image already attached" }, status: :conflict
      return
    end

    unless params[:photo].present?
      render json: { error: "No photo provided" }, status: :unprocessable_entity
      return
    end

    tagscan.image.attach(params[:photo])
    render json: {}, status: :created
  end

  # DELETE /tagscans/1
  # DELETE /tagscans/1.json
  def destroy
    @tagscan.destroy
    respond_to do |format|
      format.html { redirect_to tagscans_url, notice: "Tagscan was successfully destroyed." }
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
    params.require(:tagscan).permit(
      :tag_epc,
      :tag_pc,
      :antenna,
      :rssi,
      :received_at,
      :event_id,
      :image_protected,
      :mac,
      :source_ip,
      :reader_name,
      :hostname
    )
  end

  def resolve_reader_for_mac(mac)
    return if mac.blank?

    unless current_bearer.is_a?(AuthorizerApp)
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    reader = current_bearer.readers.find_by(mac_address: mac)
    unless reader
      render json: { error: "Forbidden" }, status: :forbidden
      return
    end

    reader
  end

  def update_reader_activity(reader, source_ip:, reader_name:, hostname:)
    reader.last_seen_at = @tagscan.received_at || Time.current
    reader.source_ip = source_ip.presence || request.remote_ip
    reader.reader_name = reader_name if reader_name.present?
    reader.hostname = hostname if hostname.present?
    reader.save! if reader.changed?
  end
end
