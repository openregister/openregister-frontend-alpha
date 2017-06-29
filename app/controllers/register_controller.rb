class RegisterController < ApplicationController

  include ApplicationHelper

  def index
    @register_records = get_register(params[:register])._all_records
    @register_fields = get_register(params[:register]).fields
  end
end
