class RegistersController < ApplicationController
  include HTTParty
  include RsfHelper

  before_action :initialize_client

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
    register = @@registers_client.get_register(params[:register], 'beta')

    fields = register.get_field_definitions.map{|field| field[:item]['field']}
    all_records = register.get_records_with_history
    entries_reversed = register.get_entries.reverse

    @entries_with_items = entries_reversed.map { |entry|
      records_for_key = all_records[entry[:key]]
      current_record = records_for_key.select{|record| record[:entry_number] == entry[:entry_number]}.first
      previous_record_index = records_for_key.find_index(current_record) - 1
      previous_record = previous_record_index >= 0 ? records_for_key[previous_record_index] : nil

      changed_fields = []

      if previous_record.nil?
        changed_fields = fields
      else
        fields.each {|f|
          if current_record[:item][f] != previous_record[:item][f]
            changed_fields << f
          end
        }
      end

      { current_record: current_record, previous_record: previous_record, updated_fields: changed_fields, key: entry[:key] }
    }

    @register_metadata = {
        phase: register.get_register_definition[:item][:phase]
    }
  end

  def show
    @register_name = params[:register]
    @register_phase = params[:phase]
    @page = params[:page] ? params[:page].to_i : 1
    @next_page = @page + 1

    register = @@registers_client.get_register(@register_name, @register_phase)

    @records = []

    if params[:current] == 'false'
      @records = register.get_expired_records
    elsif params[:current] == 'all'
      @records = register.get_records
    else
      @records_result = register.get_current_records @page
      @records = @records_result[:data]
    end

    @register_metadata = {
      last_updated: register.get_entries.last[:timestamp],
      field_definitions: register.get_field_definitions,
      register_definition: register.get_register_definition,
      custodian: register.get_custodian
    }

    @all_fields = HTTParty.get("https://field.register.gov.uk/records.json", headers: { 'Content-Type' => 'application/json' } )
  end

  def get_data
    @register_name = params[:register]
    @register_phase = params[:phase]
    register = @@registers_client.get_register(@register_name, @register_phase)

    # Necessary for rendering the _record partial view
    @register_metadata = {
        last_updated: register.get_entries.last[:timestamp],
        field_definitions: register.get_field_definitions,
        register_definition: register.get_register_definition,
        custodian: register.get_custodian
    }

    @page = params[:page] ? params[:page].to_i : 1
    @text = params[:text] ? params[:text] : ''
    @next_page = @page + 1

    @ajax_result = register.get_current_records(@page, @text)

    # render partial: 'record', collection: @ajax_result[:data]
    recordsTable = (render_to_string(partial: 'record', collection: @ajax_result[:data]))

    respond_to do |format|
      format.json {
        render :json =>
        {
          results: @ajax_result.to_json,
          recordsTable: recordsTable
        }
      }
    end
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

  def initialize_client
    @@registers_client ||= RegistersClient::RegistersClientManager.new({ cache_duration: 600 })
  end

  def register_params
    params.require(:register).permit(:name, :phase, :description, :authority)
  end
end
