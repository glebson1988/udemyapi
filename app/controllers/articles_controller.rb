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

  private

  def serializer
    ArticleSerializer
  end
end
