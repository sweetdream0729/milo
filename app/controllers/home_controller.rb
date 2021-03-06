# ================================================
# RUBY->CONTROLLER->HOME-CONTROLLER ==============
# ================================================
class HomeController < ApplicationController

  # ----------------------------------------------
  # CONCERNS -------------------------------------
  # ----------------------------------------------
  include ActionView::Helpers::NumberHelper
  include SubheaderHelper

  # ----------------------------------------------
  # VARIABLES ------------------------------------
  # ----------------------------------------------
  BASE_URL = "https://bank.shiftsavings.com?referral="

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!
  before_action :set_subheader
  before_action :set_user
  before_action :get_referral_rank, only: :index

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index

    # Check if user is a business owner
    if @user.business.present? && (@user.business.owner == @user.id)
      redirect_to works_overview_path
    else
      # Users account balance converted to dollars
      @account_balance = number_to_currency(@user.account_balance / 100.00, unit: "") if @user.account_balance
      # Users unique referral link
      @referral_link = Bitly.client.shorten(BASE_URL + current_user.id.to_s).short_url
      # Build a new goal
      @goal = @user.goals.build
      # Active Goals
      @goals = Goal.where(user_id: @user.id, active: true).order('created_at ASC')

      # Check if any goals are complete
      @goals.each do |g|
        if (g.preset && ((@user.account_balance / 100) > g.amount)) || (g.balance.to_i > g.amount)
          @goal_complete = Goal.find(g.id)
        end
      end

      # Pull in the users transactions from the current week. The week starts on Monday
      set_pending_roundups

      # Show the latest 4 transfers
      @transfers = Transfer.where(user_id: @user.id).order(date: :desc).limit(4)

      # Redirect users to proper sign up page if not complete
      if (@user.invited && !@user.is_verified)
        redirect_to signup_phone_path
      end

      # Employer Contributions
      @employer_contrib = number_to_currency(@user.employer_contribution / 100.00, unit:"") if @user.employer_contribution
      @pending_contrib = number_to_currency(@user.pending_contribution / 100.00, unit:"") if @user.pending_contribution
    end
  end

  # ----------------------------------------------
  # HISTORY --------------------------------------
  # ----------------------------------------------
  # Page to see round up transfer history
  def history
    @transfers = Transfer.where(user_id: @user.id).order(date: :desc).all
    @transfer_months = @transfers.group_by { |t| t.date.to_date.beginning_of_month }
  end

  # ----------------------------------------------
  # ROUNDUPS ------------------------------------
  # ----------------------------------------------
  def roundups
    # Completed goals
    @completed_goals = Goal.where(user_id: @user.id, completed: true).count
    # Users account balance converted to dollars
    @account_balance = number_to_currency(@user.account_balance / 100.00, unit:"") if @user.account_balance
    # Transfers
    @transfers = Transfer.where(user_id: @user.id).all
    @transfer_total = @transfers.size
    set_transfer_average(@transfers)
    # Transactions
    set_pending_roundups
    # Round Ups
    @trans = Transaction.where(user_id: @user.id).all
    @roundup_total = @trans.size
    @roundup_avg = !@trans.blank? ? number_to_currency(@trans.average(:roundup)) : "$0.00"
    # Spent
    @spent_avg = !@trans.blank? ? number_to_currency(@trans.average(:amount)) : "$0.00"
  end

  # ----------------------------------------------
  # TRANSFERS ------------------------------------
  # ----------------------------------------------
  def transfers
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SET-SUBHEADER --------------------------------
  # ----------------------------------------------
  def set_subheader
    subheader_set :savings
  end

  # ----------------------------------------------
  # SET-TRANSFER-AVERAGE -------------------------
  # ----------------------------------------------
  # transfers: All the transfers associated with the user
  # return: The average transfer amount
  def set_transfer_average(transfers)
    all_transfer_amounts = transfers.map {|tr| tr.roundup_amount.to_f }
    all_transfer_average= (all_transfer_amounts.inject{ |sum, el| sum + el }.to_f / all_transfer_amounts.size)
    @transfer_avg = (all_transfer_average > 0) ? number_to_currency(all_transfer_average) : "$0.00"
  end

  # ----------------------------------------------
  # SET-PENDING-ROUNDUPS -------------------------
  # ----------------------------------------------
  # return: This weeks pending round ups and pending round up total
  def set_pending_roundups
    @transactions = PlaidHelper.current_week_transactions(@user, @checking)
    @total_pending = 0
    @transactions.each{ |tr| @total_pending += tr[:roundup]  } if @transactions
  end

  # ----------------------------------------------
  # REFERRAL-RANK --------------------------------
  # ----------------------------------------------
  def get_referral_rank
    # @referral_rank = 1
    all_referrals = User.all.pluck("referral_code")
    # convert all referrals to hash with user id as the key and the referrals count as the value
    @referrals = all_referrals.each_with_object(Hash.new(0)) { |code,counts| counts[code] += 1 if !code.blank? }
    # use a sort + reverse to have the most referrals be at the front of the hash.
    @referrals = Hash[@referrals.sort_by(&:last).reverse]
    # find the current rank of the current user by refer. Convert to use just keys so we can find the index of the user
    # If the user has no referrals, set the rank as last AKA the total count of Users
    @referral_rank = @referrals.keys.index(@user.id.to_s) ? @referrals.keys.index(@user.id.to_s) + 1 : User.all.count
    # show the amount of referrals the user has based on their user id as the hash field or 0 if none present
    @referral_count = @referrals[@user.id.to_s] ? @referrals[@user.id.to_s] : 0
  end

end
