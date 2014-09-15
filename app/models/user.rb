class User < ActiveRecord::Base
	has_many :beekeepers
	has_many :apiaries, :through => :beekeepers

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable#, :confirmable

	# Ensure that first name and last name are entered upon registration or updating
  # validates_presence_of :first_name, :message => "can't be blank"
  # validates_presence_of :last_name, :message => "can't be blank"
  # validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.zones_map(&:name)

	# Returns the user ID associated with the specified email address
  def self.email_to_user_id(email_address)
  	user = self.find_by(email: email_address)
		user.id unless user.nil?
  end
end
