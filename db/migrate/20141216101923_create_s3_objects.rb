class CreateS3Objects < ActiveRecord::Migration
  def change
    create_table :s3_objects do |t|
      t.string :uri, uniqueness: true
      t.string :key
      t.integer :size
      t.string :md5
      t.string :content_type
      t.string :file

      t.belongs_to :bucket

      t.timestamps
    end
  end
end
