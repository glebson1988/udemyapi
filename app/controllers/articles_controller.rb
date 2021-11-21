# frozen_string_literal: true

class ArticlesController < ApplicationController
  include Paginable

  def index
    paginated = paginate(Article.recent)
    render_collection(paginated)
  end

  private

  def serializer
    ArticleSerializer
  end
end
