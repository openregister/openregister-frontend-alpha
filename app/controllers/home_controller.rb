class HomeController < ApplicationController
  include HTTParty

  def index
    @beta_registers = HTTParty.get("https://register.register.gov.uk/records.json", headers: { 'Content-Type' => 'application/json' } )
    @alpha_registers = HTTParty.get("https://register.alpha.openregister.org/records.json", headers: { 'Content-Type' => 'application/json' } )
  end
end
