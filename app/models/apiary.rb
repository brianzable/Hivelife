class Apiary < ActiveRecord::Base
	has_many :beekeepers, dependent: :destroy
	has_many :hives, -> { order 'name ASC' }, dependent: :destroy
	has_many :users, through: :beekeepers

  validates_presence_of :name, :postal_code

  def self.for_user(user)
    joins(:beekeepers)
      .where(beekeepers: { user: user })
      .includes(:hives)
      .order('name ASC')
  end
end
