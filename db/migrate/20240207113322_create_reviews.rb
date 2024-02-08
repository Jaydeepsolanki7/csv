class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.string :body
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
