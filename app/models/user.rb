class User < ActiveRecord::Base
	# dependent: :destroy means to be destroyed when the user itself is destroyed
	has_many :microposts, dependent: :destroy
    has_many :relationships, foreign_key: "follower_id", dependent: :destroy
    has_many :followed_users, through: :relationships, source: :followed


    has_many :reverse_relationships, foreign_key: "followed_id", class_name:  "Relationship", dependent:   :destroy
    has_many :followers, through: :reverse_relationships, source: :follower

	# some databases does not  support case_sensitive
	before_save { self.email = email.downcase }
    
    # remember me için eklendi
    before_create :create_remember_token

	# it is a method we can use like this => validates(:name, presence: true)
	validates :name, presence: true, length: { maximum: 50 }   

	# uniqueness: true büyük küçük harf duyarlı değil
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, length: { minimum: 6 }
    
    # remember me için eklendi
    def User.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	def User.digest(token)
	  Digest::SHA1.hexdigest(token.to_s)
	end
    
    def feed
       Micropost.from_users_followed_by(self)
    end

    def following?(other_user)
      relationships.find_by(followed_id: other_user.id)
    end

    def follow!(other_user)
      relationships.create!(followed_id: other_user.id)
    end
  
    def unfollow!(other_user)
       relationships.find_by(followed_id: other_user.id).destroy
    end

	private

	    def create_remember_token
	      self.remember_token = User.digest(User.new_remember_token)
	    end

end
