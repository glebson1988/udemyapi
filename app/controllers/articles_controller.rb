# frozen_string_literal: true

class ArticlesController < ApplicationController
  include Paginable

  skip_before_action :authorize!, only: %i[index show]

  def index
    paginated = paginate(Article.recent)
    render_collection(paginated)
  end

  def show
    article = Article.find(params[:id])
    render json: serializer.new(article)
  end

  def create
    article = Article.new(article_params)
    article.save!
    render json: serializer.new(article), status: :created
  rescue StandardError
    render json: article.errors.full_messages.to_json, status: :unprocessable_entity
  end

  private

  def serializer
    ArticleSerializer
  end

  def article_params
    params.require(:data).require(:attributes)
          .permit(:title, :content, :slug) || ActionController::Parameters.new
  end
end
