class Cms::Fortress::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    
    @user = Cms::Fortress::User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
    
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      session["devise.google_oauth2_data"] = request.env["omniauth.auth"]
      redirect_to new_cms_fortress_user_registration
    end
  end
end