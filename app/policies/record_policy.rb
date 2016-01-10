class RecordPolicy < ApplicationPolicy
  def index?
    show?
  end

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
    beekeeper.write?
  end
end
