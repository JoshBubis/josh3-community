class CreateCommunity < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :username, null: false
      t.string :password_digest, null: false
      t.text :bio
      t.boolean :admin, null: false, default: false
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true

    create_table :api_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token_digest, null: false
      t.datetime :last_used_at
      t.timestamps
    end
    add_index :api_tokens, :token_digest, unique: true

    create_table :channels do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :channels, :slug, unique: true

    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :link_url
      t.integer :score, null: false, default: 0
      t.decimal :hot_score, precision: 16, scale: 6, null: false, default: 0
      t.boolean :locked, null: false, default: false
      t.boolean :removed, null: false, default: false
      t.timestamps
    end
    add_index :posts, [ :channel_id, :hot_score ]
    add_index :posts, :created_at

    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :comments }
      t.text :body, null: false
      t.integer :score, null: false, default: 0
      t.decimal :hot_score, precision: 16, scale: 6, null: false, default: 0
      t.boolean :removed, null: false, default: false
      t.timestamps
    end
    add_index :comments, :created_at

    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :votable, polymorphic: true, null: false
      t.integer :value, null: false
      t.timestamps
    end
    add_index :votes, [ :user_id, :votable_type, :votable_id ], unique: true, name: "index_votes_on_user_and_votable"

    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reportable, polymorphic: true, null: false
      t.text :reason, null: false
      t.string :status, null: false, default: "open"
      t.timestamps
    end
    add_index :reports, [ :user_id, :reportable_type, :reportable_id ], unique: true, name: "index_reports_on_user_and_reportable"
  end
end
