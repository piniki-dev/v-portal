class CreateSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :songs do |t|
      t.references :songs_metadata, null: false, foreign_key: true, comment: 'Songs metadata ID'
      t.integer :start_time, null: false, comment: 'Song start time'
      t.integer :end_time, null: false, comment: 'Song end time'
      t.integer :track_number, null: false, comment: 'Song track number'
      t.boolean :is_full, null: false, default: true, comment: 'Is full song'
      t.string :video_id, null: false, comment: 'Video ID'
      t.timestamps
    end
    add_foreign_key :songs, :videos, column: :video_id, primary_key: :id
  end
end
