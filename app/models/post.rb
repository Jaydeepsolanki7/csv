class Post < ApplicationRecord
  has_many :reviews, dependent: :destroy
  accepts_nested_attributes_for :reviews

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "id_value", "title", "updated_at"]
  end
  def self.ransackable_associations(auth_object = nil)
    ["reviews"]
  end

  def self.import(file)
    debugger
    CSV.foreach(file.path, headers: true) do |row|
      post = Post.create!(title: row['post_title'], description: row['post_description'])
      post.reviews.create!(body: row['review_body']) if row['review_body'].present?
    end
  end

  def self.to_csv(post = nil)
    attributes = %w[id title description review_body] # Add more attributes as needed

    CSV.generate(headers: true) do |csv|
      csv << attributes

      if post.present?
        post.reviews.each do |review|
          csv << [post.id, post.title, post.description, review.body]
        end
      else
        all.each do |post|
          post.reviews.each do |review|
            csv << [post.id, post.title, post.description, review.body]
          end
        end
      end
    end
  end

  def self.to_csv_all
    to_csv
  end
end
