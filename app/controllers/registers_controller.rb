class RegistersController < ApplicationController
  include HTTParty
  include RsfHelper

  def index
    if params[:phase] == 'Ready to use'
      @registers = Register.where(phase: 'Beta').by_name
    elsif params[:phase] == 'In progress'
      @registers = Register.where.not(phase: 'Beta').by_name
    else
      @registers = Register.sort_by_phase_name_asc.by_name
    end
  end

  def entries
    @register_meta_data = HTTParty.get("https://#{params[:register]}.beta.openregister.org/register.json", headers: { 'Content-Type' => 'application/json' } )
    @entries_with_items = get_entries
  end

  def show
    @records = OpenRegister.register(params[:register], params[:phase].to_sym)._all_records

    if params[:current] == 'true'
      @records = @records.select{ |x| x.end_date.blank? }
    elsif params[:current] == 'false'
      @records = @records.select{ |x| x.end_date.present? }
    end

    @register_meta_data = HTTParty.get("https://#{params[:register]}.#{params[:phase]}.openregister.org/register.json", headers: { 'Content-Type' => 'application/json' } )

    @all_fields = HTTParty.get("https://field.register.gov.uk/records.json", headers: { 'Content-Type' => 'application/json' } )
  end

  def new
    @register = Register.new
  end

  def edit
    @register = Register.find(params[:id])
  end

  def create
    @register = Register.new(register_params)
    if @register.save
      flash.now[:success] = "Successfull saved"
      redirect_to registers_path
    else
      flash.now[:alert] = "Please check errors"
      render :new
    end
  end

  def update
    @register = Register.new(register_params)
    if @register.update_attributes(register_params)
      flash.now[:success] = "Successfully saved"
      redirect_to registers_path
    else
      flash.now[:alert] = "Please check errors"
      render :edit
    end
  end

  def destroy
    @register = Register.find(params[:id])
    @register.destroy
    flash.now[:success] = "Register deleted from pipeline"
    redirect_to registers_path
  end

  private

  def register_params
    params.require(:register).permit(:name, :phase, :description, :authority)
  end
end
