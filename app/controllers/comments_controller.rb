# frozen_string_literal: true

class CommentsController < ApplicationController
  include Paginable

  skip_before_action :authorize!, only: :index

  def index
    paginated = paginate(article.comments)
    render_collection(paginated)
  end

  def create
    comment.save!
    render json: serializer.new(comment), status: :created, location: article
  rescue StandardError
    render json: comment.errors, status: :unprocessable_entity
  end

  private

  def serializer
    CommentSerializer
  end

  def article
    @article ||= Article.find(params[:article_id])
  end

  def comment
    @comment ||= article.comments.build(comment_params.merge(user: current_user))
  end

  def comment_params
    params.require(:data).require(:attributes).permit(:content) || ActionController::Parameters.new
  end
end
