class Cms::Fortress::User < ActiveRecord::Base
  # set_table_name :cms_fortress_users
  self.table_name = "cms_fortress_users"

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable,
  #        :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
       :omniauthable, :omniauth_providers => [:google_oauth2]

  # devise :omniauthable, :omniauth_providers => [:google_oauth2]

  belongs_to :role
  belongs_to :site, class_name: "Comfy::Cms::Site", foreign_key: :site_id

  scope :all_super, -> { where(type_id: 1) }

  def self.types
    {
      1 => :super_user,
      2 => :site_user
    }
  end

  def type
    self.class.types[type_id]
  end

  def display_name
    "#{ email } (#{ type.to_s.titleize })"
  end


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.encrypted_password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.image = auth.info.image
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.google_oauth2_data"] && session["devise.google_oauth2_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

end
