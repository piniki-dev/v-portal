class CreateProductions < ActiveRecord::Migration[7.1]
  def change
    create_table :productions do |t|
      t.string :name, null: false, comment: 'Production name'
      t.boolean :delete_flag, null: false, default: false, comment: 'Delete flag'
      t.datetime :deleted_at, comment: 'Deleted at'
      t.timestamps
    end
  end
end
