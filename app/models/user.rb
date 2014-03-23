class User < ActiveRecord::Base
  has_many :my_schools
  validates_presence_of :email, :password
  validates_uniqueness_of :email
# validates_length_of :password, :in=>6..15
  
  def before_create
    self.password=Digest::SHA1.hexdigest(self.password)
  end
  
  def after_create
    @password=nil
  end
  
  def self.login(email, password)
    User.find_by_email_and_password(email, Digest::SHA1.hexdigest(password))
    #find(:first, :conditions => ["email = ? and password = ?", 
    #                              email, Digest::SHA1.hexdigest(password)])
  end
  
  def try_to_login
    User.login(self.email, self.password)
  end

end
