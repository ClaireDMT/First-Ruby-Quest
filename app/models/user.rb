class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Write associations and validations here
  has_many :issues, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :issue_tags, through: :issues
  has_many :tags, through: :issue_tags

  validates :username, uniqueness: true, presence: true
  validates :github_url, uniqueness: true, allow_blank: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :password, length: { minimum: 6 }
  def bookmark!(issue)
    bookmarks << Bookmark.create(issue: issue)
  end
end
