class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :require_character_name_chosen
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end

  def after_sign_in_path_for(resource)
    if resource.respond_to?(:pj?) && resource.pj? && !resource.character_name_chosen?
      new_character_name_path
    else
      root_path
    end
  end

  def require_character_name_chosen
    return unless user_signed_in?
    return unless current_user.respond_to?(:pj?) && current_user.pj?
    return if current_user.character_name_chosen?
    return if devise_controller?

    redirect_to new_character_name_path
  end
end
