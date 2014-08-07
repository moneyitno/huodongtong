#encoding: utf-8
class UsersController < ApplicationController
  def welcome
    session[:name] = "" 
    user = User.where(:identity => "user")
    @user = user.paginate(page: params[:page],per_page:10)
  end

  def signup
    @user = User.new
  end

  def login

  end

  def create
    params[:user][:identity] = "user"
    p params[:user]
    @user = User.new(params[:user])
    if current_user
      if current_user.identity == "admin"
        if @user.save
          redirect_to  :welcome
        else
          render :adduser
        end
      end
    else
      if @user.save
        cookies.permanent[:token] = @user.token
        redirect_to :welcome
      else
        render :signup
      end
    end
  end

  def logout
    cookies.delete(:token)
    redirect_to :login
  end

  def create_login_session
    user = User.find_by_name(params[:name])
    if user && user.authenticate(params[:password])
      cookies.permanent[:token] = user.token
      redirect_to :welcome
    else
      flash[:error] = "用户名不存在或密码错误"
      redirect_to :login
    end
  end

  def adduser
    @user = User.new
  end

  def delete_user
    User.find_by_name(params[:delete_name]).delete
    redirect_to :welcome
  end

  def change_password_session
    user = User.find_by_name(session[:name])
    if params[:password] == params[:password_confirmation] && params[:password] != ""
      redirect_to :welcome
    else
      flash[:error] = "密码输入不一致"
      redirect_to :password
    end
  end

  def password
    if session[:name] == ""
      session[:name] = params[:change_name]
    end
  end
end
