require "open-uri"

class Issue < ApplicationRecord
  include PgSearch::Model
  has_rich_text :description

  belongs_to :user, optional: true
  has_many :bookmarks, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :issue_tags, dependent: :destroy
  has_many :tags, through: :issue_tags

  validates :title, presence: true
  validates :category, presence: true
  # only for open_source issues
  # several call_to_action issues can have an empty string as a url
  validates :url, uniqueness: true, if: :open_source?
  validates :url, presence: true, if: :open_source?
  validates :repo_name, presence: true, if: :open_source?
  validates :repo_url, presence: true, if: :open_source?
  validates :github_id, presence: true, if: :open_source?
  # only for call_to_action issues
  validates :description, presence: true, if: :call_to_action?
  validates :user_id, presence: true, if: :call_to_action?

  enum category: %i[open-source call_to_action]

  pg_search_scope :search_by_keyword, against: [:title, :description, :repo_name]

  def self.find_issues
    issues = GithubApi.new.search_issues.items
    active_issues = []
    issues.each do |issue|
      i = IssueGenerator.new(issue).create
      active_issues << i
    end

    issues_no_longer_available = Issue.where(category: "open-source") - active_issues
    issues_no_longer_available.each do |issue|
      issue.update(available: false)
    end
  end
end
