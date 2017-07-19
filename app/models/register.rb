class Register < ApplicationRecord
  require 'openregister'

  CURRENT_PHASES = ['Backlog', 'Discovery', 'Alpha', 'Beta']
  AUTHORITIES = OpenRegister.register('government-organisation', :beta)._all_records.reject{ |r| r.end_date.present? }.sort_by(&:name).map(&:name)

  validates_presence_of :name, :phase
  validates_uniqueness_of :name

  scope :by_phase, -> (phase) { where phase: phase }
  scope :by_name, -> { order name: :asc }
  scope :sort_by_phase_name_asc, -> { order("CASE phase WHEN 'Beta' THEN 2 WHEN 'Alpha' THEN 3 WHEN 'Discovery' THEN 4 WHEN 'Backlog' THEN 5 END") }
  scope :sort_by_phase_name_desc, -> { order("CASE phase WHEN 'Backlog' THEN 1 WHEN 'Discovery' THEN 2 WHEN 'Alpha' THEN 3 WHEN 'Beta' THEN 4 END") }

end
