class CreateAcl < ActiveRecord::Migration
  def change
    create_table :acls do |t|
      t.string :name, default: 'You'
      t.string :permission, default: 'FULL_CONTROL'

      t.belongs_to :bucket
    end
  end
end
