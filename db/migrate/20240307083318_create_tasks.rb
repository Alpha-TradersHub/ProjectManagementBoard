class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.date :due_date
      t.date :completed_date
      t.decimal :progress, default: 0
      t.integer :status, default: 0
      t.integer :priority, default: 0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
