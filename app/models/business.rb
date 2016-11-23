# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  name                             :string
#  address                          :string
#  city                             :string
#  state                            :string
#  zip                              :string
#  contribution                     :decimal          precision, 2
#

# ================================================
# RUBY->MODEL->BUSINESS ==========================
# ================================================
class Business < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  has_many :users

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validates :name, presence: true

end
