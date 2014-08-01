class ApiaryPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end # end scope

  def index?
    true # Anyone can view the index
  end

  def show?
    beekeeper.read?
  end

  def new?
    true # Anyone can create a new apiary
  end

  def create?
    true # Anyone can create a new apiary
  end

  def edit?
    beekeeper.admin?
  end

  def update?
    beekeeper.admin?
  end

  def destroy?
    beekeeper.admin?
  end
end
