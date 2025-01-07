class CreateSongsMetadata < ActiveRecord::Migration[7.1]
  def change
    create_table :songs_metadata do |t|
      t.string :title, null: false, comment: 'Track title'
      t.string :artist, null: false, comment: 'Track artist'
      t.timestamps
    end
  end
end
