class BeekeeperPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def index?
    beekeeper.read?
  end

  def show?
    beekeeper.read?
  end

  def create?
    beekeeper.admin?
  end

  def update?
    beekeeper.admin? && !record.admin?
  end

  def destroy?
    return true if beekeeper == record
    beekeeper.admin? && !record.admin?
  end
end
