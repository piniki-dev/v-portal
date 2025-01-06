class CreateVideos < ActiveRecord::Migration[7.1]
  def up
    # stream_typeをENUMで定義
    execute <<-SQL
      CREATE TYPE video_type AS ENUM ('karaoke', 'cover', 'talk', 'game', 'other', 'uncategorized');
    SQL

    create_table :videos, id: false do |t|
      t.string :id, null: false, primary_key: true, comment: 'Video ID'
      t.string :title, null: false, comment: 'Video title'
      t.text :description, null: false, comment: 'Video description'
      t.bigint :duration, null: false, comment: 'Video duration'
      t.string :thumbnail, null: false, comment: 'Video thumbnail'
      t.datetime :published_at, null: false, comment: 'Video published at'
      t.bigint :view_count, null: false, comment: 'Video view count'
      t.bigint :like_count, null: false, comment: 'Video like count'
      t.bigint :comment_count, null: false, comment: 'Video comment count'
      t.datetime :actual_start_time, comment: 'Video actual start time'
      t.datetime :actual_end_time, comment: 'Video actual end time'
      t.column :type, :video_type, null: false, default: 'uncategorized', comment: 'Type of video'
      t.string :channel_id, null: false, comment: 'Channel ID'
      t.timestamps
    end
    add_foreign_key :videos, :channels, column: :channel_id, primary_key: :id
  end

  def down
    drop_table :videos
    execute <<-SQL
      DROP TYPE video_type;
    SQL
  end
end
