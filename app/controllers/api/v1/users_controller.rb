class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]




  def stats
    user = User.find_by(username: params[:user])
    novel = user.novels.find_by(title: params[:novel])
    chapters = novel.chapters


 colors = ['#b52b65', '#bd3a67', '#c44768', '#cc546a', '#d35f6b', '#db6b6d', '#e2766e', '#e9826f', '#f18d70', '#f89871', '#df5d62', '#d15461', '#c2e8ce', '#f2eee5', '#f6ad7b', '#be7575', '#dcffcc', '#9fdfcd', '#baabda', '#d79abc']

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
  templateObject = {
    full: 0
  }

  tempwords = {}

  chapters.each_with_index do |item, index|
    templateObject["#{item.title}"] = 0
  end


totalWords= 0
wordLengthChecker = 0
templongestWord = ""
totalCharacters = 0

  chapters.each_with_index do |item, index|
      tempchapters.push({:label => item.title, :data => [], :backgroundColor => colors.pop(), :barThickness => 8})

      w = item[:content].split(' ')
      w.each do |w|
        totalWords += 1
        totalCharacters += w.length
        if w.length > wordLengthChecker
          wordLengthChecker = w.length
          templongestWord = w 
        end

        if tempwords[w.downcase]
          tempwords[w.downcase][:full] += 1
          tempwords[w.downcase]["#{item.title}"] += 1
        else
          a = templateObject.dup
          tempwords[w.downcase] = a
          tempwords[w.downcase][:full] += 1
          tempwords[w.downcase]["#{item.title}"] += 1
        end
      end
  end

tempwords = tempwords.sort_by {|_key, value| -value[:full]}.to_h


counter = 0
tempwords.each do |k,v|
    response[:wordList][:words].push(k)
    response[:wordList][:chapters].each do |item|
      item[:data].push(v[item[:label]])
      end
end



response[:wordCount] = totalWords
response[:numberOfUniqueWords] = tempwords.length
response[:longestWord] = templongestWord
response[:avgWordLength] = totalCharacters / totalWords

  

    render json: response
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
