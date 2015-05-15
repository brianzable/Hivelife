class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    user_matches_record?
  end

  def create?
    user_matches_record?
  end

  def update?
    user_matches_record?
  end

  def destroy?
    user_matches_record?
  end

private

  def user_matches_record?
    @user == @record
  end
end
