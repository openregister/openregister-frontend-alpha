class HomeController < ApplicationController
  def index
    @registers = OpenRegister.register('register', :beta)._all_records.sort_by(&:key)
  end
end
