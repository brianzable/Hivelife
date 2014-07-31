class BeekeeperPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end # end scope

  def show?
    beekeeper.read?
  end

  def create?
    beekeeper.admin?
  end

  def update?
    beekeeper.admin?
  end

  def destroy?
    beekeeper.admin?
  end
end
