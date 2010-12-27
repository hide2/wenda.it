class User
  include MongoMapper::Document

  key :name,              String
  key :salt,              String
  key :crypted_password,  String
  key :email,             String
  key :avatar_path,       String
  key :views_count,       Integer, :default => 0
  key :last_login,        Time
  timestamps!
  
  many :questions
  many :answers
  many :badges
  
  def password=(pass)
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.salt, self.crypted_password = salt, Digest::SHA256.hexdigest(pass + salt)
  end

  def self.authenticate(name, password)
    user = User.find_by_name(name)
    if user.nil?
      return nil
    elsif Digest::SHA256.hexdigest(password + user.salt) != user.crypted_password
      return nil
    end
    user
  end
  
  def self.recent(limit = LIMIT)
    all(:limit => limit, :order => "created_at DESC")
  end
  
  def self.paginate(page = 1, limit = 35)
    raise "Wrong page" if page.to_i < 1
    all(:limit => limit, :offset => (page.to_i-1)*limit, :order => "created_at DESC")
  end
  
  def self.search(keyword)
    all(:name => /#{keyword}/, :limit => 35, :order => "created_at DESC")
  end
  
  def save_avatar(img)
    img_name = self.id.to_s + "." + img.original_filename.split(".").last
    directory = AVATAR_PATH
    abs_directory = Rails.root.to_s + "/public" + directory
    if !File.exist?(abs_directory)
      Dir.mkdir abs_directory
    end
    img_path = File.join(directory, img_name)
    abs_path = Rails.root.to_s + "/public" + img_path
    File.open(abs_path, "wb") { |f| f.write(img.read) }
    self.avatar_path = img_path
    self.save
  end
  
  def avatar
    self.avatar_path.blank?
  end
  
end
