class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.string :code
      t.string :message
      t.string :resource
      t.integer :request_id,	default: 1
    end
  end
end
