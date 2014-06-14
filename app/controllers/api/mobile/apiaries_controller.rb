class Api::Mobile::ApiariesController < ApplicationController
  doorkeeper_for :all
  def index
    user_id = doorkeeper_token.resource_owner_id
    @apiaries = Apiary.joins(:beekeepers)
                      .where('beekeepers.user_id = ?', user_id)
    render :json => user_id
  end
end
