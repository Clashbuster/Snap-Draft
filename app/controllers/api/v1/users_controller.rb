class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]




  def stats
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])
    novel = user.novels.find_by(title: params[:novel])
    chapters = novel.chapters


#  colors = ['#b52b65', '#bd3a67', '#c44768', '#cc546a', '#d35f6b', '#db6b6d', '#e2766e', '#e9826f', '#f18d70', '#f89871', '#df5d62', '#d15461', '#c2e8ce', '#f2eee5', '#f6ad7b', '#be7575', '#dcffcc', '#9fdfcd', '#baabda', '#d79abc']
#  colors = ['#50d890', '#50cd9a', '#50c1a5', '#4fb5b0', '#4fa9ba', '#4f9dc6', '#4d92c2', '#4a89b5', '#4781a8', '#44789c', '#417090', '#3e6783', '#3b5f77', '#38566b', '#354e60', '#324654', '#2f3e49', '#2c363d', '#2a2f32', '#272727']
colors = ['#272727', '#2a2f32', '#2c363d', '#2f3e49', '#324654', '#354e60', '#38566b', '#3b5f77', '#3e6783', '#417090', '#44789c', '#4781a8', '#4a89b5', '#4d92c2', '#4f9dc6', '#4fa9ba', '#4fb5b0', '#50c1a5', '#50cd9a', '#50d890']

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
      tempchapters.push({:label => item.title, :data => [], :backgroundColor => colors.pop(), :barThickness => 17})

      w = item[:content].split(' ')
      w.each do |w|
        totalWords += 1
        totalCharacters += w.length
        w.gsub!(/[^0-9A-Za-z]/, '')
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
response[:numberOfUniqueWords] = tempwords.length


top100Words = ["the","of","and","a","to","in","is","you","that","it","he","was","for","on","are","as","with","his","they","i","at","be","this","have","from","or","one","had","by","word","but","not","what","all","were","we","when","your","can","said","there","use","an","each","which","she","do","how","their","if","will","up","other","about","out","many","then","them","these","so","she","some","her","would","make","like","him","into","time","has","look","two","more","write","go","see","number","no","way","could","people","my","than","first","water","been","call","who","oil","its","now","find","long","down","day","did","get", "come", "made", "may", "part"]
# top100Words = ["", ""]

top100Words.each do |item|

if tempwords["#{item}"]
tempwords.delete(item)
  end
end
# puts tempwords

keycounter = 0
tempwords.each do |k,v|

 break if keycounter === 65


    response[:wordList][:words].push(k)
    response[:wordList][:chapters].each do |item|
      item[:data].push(v[item[:label]])
      end

      keycounter += 1
end



response[:wordCount] = totalWords
response[:longestWord] = templongestWord

if totalWords != 0
response[:avgWordLength] = totalCharacters / totalWords
else
response[:avgWordLength] = 0
end

  

    render json: response
  end



  def delete_novel
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])
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
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])

    novel = user.novels.find_by(title: params[:novel])
    
    if novel.chapters.find_by(title: params[:chapter])
    chapter = novel.chapters.find_by(title: params[:chapter])
    chapter.content += params[:text]
    chapter.save
    elsif params[:chapter] != ""
      chapter = novel.chapters.create(title: params[:chapter], content: params[:text])
      chapter.save
    elsif novel.chapters.last == nil
      chapter = novel.chapters.create(title: "Chapter 1")
      chapter.content = params[:text]
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
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])
    novel = user.novels.find_by(title: params[:novel])
    chapters = novel.chapters
    
    render json: chapters
  end

  def new_novel
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])
    novel = user.novels.create(title: params[:title], sprint_increment: params[:sprintIncrement])
    novel.save
    if params[:chapterTitle] != ""
      chapter = novel.chapters.create(title: params[:chapterTitle], content: "")
      chapter.save
    end
    render json: novel
  end


  def update_sprint
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])
    novel = user.novels.find_by(title: params[:novel])
    novel.sprint_increment = params[:newSprint]
    novel.save

    render json: novel
  end

  def show
    decodedtoken = decoded_token()
    user = User.find_by(id: decodedtoken[0]["user_id"])

    response = user.novels
    



    render json: response
  end
 
  private
 
  def user_params
    params.require(:user).permit(:username, :password)
  end
end
