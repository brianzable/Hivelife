class ContactRequestsController < ApplicationController
  def create
    @contact_request = ContactRequest.new(contact_request_params)

    if @contact_request.save
      head :created
    else
      render json: @contact_request.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def contact_request_params
    params.require(:contact_request).permit(
      :name,
      :email_address,
      :subject,
      :message
    )
  end
end
