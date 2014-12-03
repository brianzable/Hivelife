class StaticPagesController < ApplicationController
	def index
	end

	def data
	end

	def add_email
		signup_params = params.require(:landing_page_signup).permit(:email_address)
		signup = LandingPageSignup.new(signup_params)
		respond_to do |format|
			if signup.save
				format.json { render json: {}, status: :ok }
			else
				format.json { render json: {}, status: :unprocessable_entity }
			end
		end
	end
end
