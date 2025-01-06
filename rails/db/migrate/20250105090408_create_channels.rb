class CreateChannels < ActiveRecord::Migration[7.1]
  def change
    create_table :channels, id: false do |t|
      t.string :id, null: false, primary_key: true, comment: 'Channel ID'
      t.string :title, null: false, comment: 'Channel title'
      t.string :handle, null: false, comment: 'Channel handle'
      t.text :description, null: false, comment: 'Channel description'
      t.string :thumbnail, null: false, comment: 'Channel thumbnail'
      t.references :vtuber, null: false, foreign_key: true, comment: 'Vtuber ID'
      t.boolean :delete_flag, null: false, default: false, comment: 'Delete flag'
      t.datetime :deleted_at, comment: 'Deleted at'
      t.timestamps
    end
  end
end
