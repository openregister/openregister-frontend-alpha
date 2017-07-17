class RegisterController < ApplicationController

  include HTTParty
  include ApplicationHelper
  include RsfHelper

  def index
    @records = OpenRegister.register(params[:register], params[:phase].to_sym)._all_records

    if params[:current] == 'true'
      @records = @records.select{ |x| x.end_date.blank? }
    elsif params[:current] == 'false'
      @records = @records.select{ |x| x.end_date.present? }
    end

    @register_meta_data = HTTParty.get("https://#{params[:register]}.#{params[:phase]}.openregister.org/register.json", headers: { 'Content-Type' => 'application/json' } )

    @all_fields = HTTParty.get("https://field.register.gov.uk/records.json", headers: { 'Content-Type' => 'application/json' } )
  end

  def entries
    @register_meta_data = HTTParty.get("https://#{params[:register]}.beta.openregister.org/register.json", headers: { 'Content-Type' => 'application/json' } )
    @entries_with_items = get_entries
  end
end
