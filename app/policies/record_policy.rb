class RecordPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
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
