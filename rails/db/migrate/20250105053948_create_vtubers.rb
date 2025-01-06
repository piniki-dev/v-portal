class CreateVtubers < ActiveRecord::Migration[7.1]
  def up
    # genderをENUMで定義
    execute <<-SQL
      CREATE TYPE gender_type AS ENUM ('male', 'female', 'other', 'unknown');
    SQL

    create_table :vtubers do |t|
      t.string :name, null: false, comment: 'Name'
      t.column :gender, :gender_type, null: false, default: 'unknown', comment: "Gender"
      t.datetime :birthday, comment: 'Birthday'
      t.datetime :debut, comment: 'Debut date'
      t.references :production, null: false, foreign_key: true, comment: 'Production ID'
      t.boolean :delete_flag, null: false, default: false, comment: 'Delete flag'
      t.datetime :deleted_at, comment: 'Deleted at'
      t.timestamps
    end
  end

  def down
    drop_table :vtubers
    execute <<-SQL
      DROP TYPE gender_type;
    SQL
  end
end
