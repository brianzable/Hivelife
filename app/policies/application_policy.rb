class ApplicationPolicy
  attr_reader :beekeeper, :record

  def initialize(beekeeper, record)
    @beekeeper = beekeeper
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(beekeeper, record.class)
  end
end
