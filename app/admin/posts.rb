# app/admin/posts.rb
ActiveAdmin.register Post do
  permit_params :title, :description, reviews_attributes: [:id, :body, :_destroy]


  index do
    selectable_column
    id_column
    column :title
    column :description
    column 'Reviews' do |post|
      post.reviews.pluck(:body).join(', ')
    end
    actions
    column 'Download CSV' do |post|
      link_to 'Download', export_csv_admin_post_path(post, format: :csv)
    end
  end

  form do |f|
    f.inputs 'Post Details' do
      f.input :title
      f.input :description, as: :text
      # column 'Download CSV' do
      #   link_to 'Download', export_csv_admin_post_path(f.object, format: :csv)
      # end
    end

    f.inputs 'Reviews' do
      f.has_many :reviews, allow_destroy: true do |review_form|
        review_form.input :body
      end
    end

    f.actions
  end

  member_action :export_csv, method: :get do
    post = Post.find(params[:id])
    csv_data = Post.to_csv(post)
    send_data csv_data, filename: "post_#{post.id}_with_reviews.csv"
  end

  collection_action :export_csv, method: :get do
    csv_data = Post.to_csv_all
    send_data csv_data, filename: "all_posts_with_reviews.csv"
  end

  show do
    attributes_table do
      row :title
      row :description
    end

    panel 'Reviews' do
      table_for post.reviews do
        column :body
      end
    end

    active_admin_comments
  end

  action_item :import_csv, only: :index do
    link_to 'Import CSV', action: 'import_csv'
  end

  collection_action :import_csv do
    render 'layouts/admin/posts/import_csv'
  end

  collection_action :process_csv, method: :post do
    debugger
    Post.import(params[:file])
    redirect_to admin_posts_path, notice: 'CSV imported successfully!'
  end
end
