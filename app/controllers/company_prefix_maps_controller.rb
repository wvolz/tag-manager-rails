class CompanyPrefixMapsController < ApplicationController
  before_action :require_admin
  before_action :set_company_prefix_map, only: %i[edit update destroy]

  def index
    @company_prefix_maps = CompanyPrefixMap.order(:decoder, :company_prefix)
  end

  def new
    @company_prefix_map = CompanyPrefixMap.new(active: true)
  end

  def create
    @company_prefix_map = CompanyPrefixMap.new(company_prefix_map_params)

    if @company_prefix_map.save
      redirect_to company_prefix_maps_path, notice: "Company prefix mapping was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company_prefix_map.update(company_prefix_map_params)
      redirect_to company_prefix_maps_path, notice: "Company prefix mapping was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company_prefix_map.destroy
    redirect_to company_prefix_maps_path, notice: "Company prefix mapping was successfully deleted."
  end

  private

  def set_company_prefix_map
    @company_prefix_map = CompanyPrefixMap.find(params[:id])
  end

  def company_prefix_map_params
    params.require(:company_prefix_map).permit(:decoder, :company_prefix, :company_name, :active, :notes)
  end
end
