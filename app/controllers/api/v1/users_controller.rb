class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]




  def stats
    user = User.find_by(username: params[:user])
    novel = user.novels.find_by(title: params[:novel])
    chapters = novel.chapters

  response = {
    :wordCount => 0,
    :longestWord => "",
    :avgWordLength => 0,
    :numberOfUniqueWords => 0,
    :wordList =>  {
      :words => [],
      :chapters => []
    }
  }
    
  wordList = response[:wordList]
  tempchapters = response[:wordList][:chapters]
  tempwords = {}
  tempwordsarr = []


  chapters.each_with_index do |item, index|
      tempchapters.push({:label => item.title})
      w = item[:content].split(' ')
      w.each do |w|

        if tempwords[w.downcase]
          tempwords[w.downcase] += 1
        else
          tempwords[w.downcase] = 1
        end
      end
  end

tempwords.each do |k, v|
  tempwordsarr.push(k)
end



response[:wordList][:words] = tempwordsarr


tempwords = tempwords.sort_by {|_key, value| -value}.to_h
  

    render json: tempwords
  end



  def delete_novel
    user = User.find_by(username: params[:user])
    novel = user.novels.find_by(title: params[:novel])
    Novel.delete(novel.id)

    render json: novel
  end
 
  def profile
    render json: { user: UserSerializer.new(current_user) }, status: :accepted
  end
 
  def create
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token({ user_id: @user.id })
      render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  def sprint
    user = User.find_by(username: params[:user])
    puts user
    novel = user.novels.find_by(title: params[:novel])
    
    if params[:chapter] != ""
      chapter = novel.chapters.create(title: params[:chapter], content: params[:text])
      chapter.save
    else
      chapter = novel.chapters.last
      chapter.content += params[:text]
      chapter.save
    end

    if novel.sprint_count
      novel.sprint_count += 1
    else
      novel.sprint_count = 1
    end

    novel.save
    chapters = novel.chapters

    render json: chapters
  end

  def chapters
    user = User.find_by(username: params[:user])
    novel = user.novels.find_by(title: params[:novel])
    chapters = novel.chapters

    render json: chapters
  end

  def new_novel
    user = User.find_by(username: params[:user])
    novel = user.novels.create(title: params[:title], sprint_increment: params[:sprintIncrement])
    novel.save
    if params[:chapterTitle] != ""
      chapter = novel.chapters.create(title: params[:chapterTitle], content: "")
      chapter.save
    end
    render json: novel
  end

  def show
    
    user = User.find_by(username: params[:username])
    
    render json: user.novels
  end
 
  private
 
  def user_params
    params.require(:user).permit(:username, :password)
  end
end
