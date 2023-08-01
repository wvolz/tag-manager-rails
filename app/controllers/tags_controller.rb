class TagsController < ApplicationController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  before_action :set_tag_by_epc, only: [:authorize]
  before_action :require_login, only: [:index, :show, :edit, :update, :destroy, :new]
  helper_method :sort_column, :sort_direction

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.order(sort_column + " " + sort_direction)
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
    @auth_response = "unauthorized"
    @db_result = nil
    if @tag.authorizations.exists?(params[:a])
      @db_result = @tag.authorizations.find(params[:a])
      if @db_result
        @auth_response = "authorized"
      end
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
end
