# == Schema Information
#
# Table name: businesses
#
#  id                   :integer          not null, primary key
#  name                 :string
#  created_at           :datetime
#  updated_at           :datetime
#  frequency            :string
#  owner                :integer
#  current_contribution :integer
#  total_contribution   :integer
#  max_contribution     :integer
#  match_percent        :integer
#

# ================================================
# RUBY->MODEL->BUSINESS ==========================
# ================================================
class Business < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  has_many :users
  has_many :transfers

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validates :name, presence: true

  def self.add_business_owner(user, business_id)
    biz = Business.find(business_id)
    biz.owner = user.id

    biz.save!
  end

  # reset current_contribution to nil after all user round ups were taken
  def self.reset_current_contribution(business_id)
    biz = Business.find(business_id)
    biz.current_contribution = nil

    biz.save!
  end

end
