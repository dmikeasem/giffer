class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def search
  end

  # GET /users/[username]
  # GET /users/[username].json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.where(username: params[:username]).take
    end
end
