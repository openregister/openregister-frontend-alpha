class CreateRegisters < ActiveRecord::Migration[5.1]
  def change
    create_table :registers do |t|
      t.string :name
      t.string :phase
      t.string :authority
      t.text :description
      t.timestamps
    end
  end
end
