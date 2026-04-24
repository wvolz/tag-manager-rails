class AuthorizerAppsController < ApplicationController
  before_action :require_admin
  before_action :set_authorizer_app

  def show
  end

  def edit
  end

  def update
    if @authorizer_app.update(authorizer_app_params)
      redirect_to authorizer_app_path, notice: "Authorizer app was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_authorizer_app
    @authorizer_app = current_authorizer_app
    return if @authorizer_app.present?

    @authorizer_app = AuthorizerApp.create!(name: "Primary Authorizer", description: "Default authorizer app")
  end

  def authorizer_app_params
    params.require(:authorizer_app).permit(:name, :description)
  end
end
