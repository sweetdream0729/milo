# == Schema Information
#
# Table name: public_tokens
#
#  id      :integer          not null, primary key
#  token   :string
#  user_id :string
#

require 'rails_helper'

RSpec.describe PublicToken, type: :model do

  # it "adds checking with user and plaid account" do
  #   Account.create_long_tail_account(@plaid_user.accounts, @pt, @user.id)
  #
  #   expect(Account.first.long_tail).to eq(true)
  # end
end
