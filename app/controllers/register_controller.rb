class RegisterController < ApplicationController

  include HTTParty
  include ApplicationHelper

  def index
    @records = HTTParty.get("https://#{params[:register]}.#{params[:phase]}.openregister.org/records.json?page-size=5000", headers: { 'Content-Type' => 'application/json' } )
    @register_meta_data = HTTParty.get("https://#{params[:register]}.#{params[:phase]}.openregister.org/register.json", headers: { 'Content-Type' => 'application/json' } )

    @all_fields = HTTParty.get("https://field.register.gov.uk/records.json", headers: { 'Content-Type' => 'application/json' } )
  end
end
