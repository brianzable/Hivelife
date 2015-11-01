class Apiary < ActiveRecord::Base
	has_many :beekeepers, dependent: :destroy
	has_many :hives, dependent: :destroy
	has_many :users, through: :beekeepers

  def self.for_user(user)
    self.joins(:beekeepers)
        .where(beekeepers: { user: user })
        .includes(:hives)
  end
end
