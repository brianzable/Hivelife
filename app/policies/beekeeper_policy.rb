class BeekeeperPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end # end scope

  def show?
    beekeeper.read? unless beekeeper.nil?
  end

  def create?
    beekeeper.admin? unless beekeeper.nil?
  end

  def update?
    beekeeper.admin? unless beekeeper.nil?
  end

  def destroy?
    beekeeper.admin? unless beekeeper.nil?
  end
end
