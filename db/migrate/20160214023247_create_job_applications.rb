class CreateJobApplications < ActiveRecord::Migration[5.1]
  def change
    create_table :job_applications do |t|
      t.integer :job_listing_id
      t.integer :user_id
      t.text    :cover_letter
      t.timestamps null: false
    end
  end
end
