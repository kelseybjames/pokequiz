class User < ActiveRecord::Base
  include AnswerStats

  has_one :profile, dependent: :destroy
  has_many :activities
  has_many :results

  has_many :initiated_followings, class_name: 'Following', dependent: :destroy
  has_many :followeds, through: :initiated_followings, class_name: 'User'

   has_many :received_followings, class_name: 'Following', dependent: :destroy
   has_many :followers, through: :received_followings, class_name: 'User' 

   validates :password, 
            :length => { :in => 8..24 }, 
            :allow_nil => true
  validates :email, presence: true

  def generate_token
    begin
    self[:auth_token] = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: self[:auth_token])
  end

  def regenerate_auth_token
    self.auth_token = nil
    generate_token
    save!
  end
end
