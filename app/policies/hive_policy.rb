class HivePolicy < ApplicationPolicy
  def show?
    beekeeper.read?
  end

  def create?
    beekeeper.write?
  end

  def update?
    beekeeper.write?
  end

  def destroy?
    beekeeper.admin?
  end
end
