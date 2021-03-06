module Contribution
  # Run the employer contribution for the current user
  #
  # @param [object] user current user
  # @param [integer] amount_in_cents current round up amount_in_cents
  def self.run_employer_contribution(user, amount_in_cents)
    @amount = amount_in_cents
    @user = user
    @employer = Business.find(@user.business_id)

    # check to make sure the max employer contribution (in cents) is less than already contributed to the employee. Also need to check pending contributions
    if Contribution.max_contribution_not_met
      # employer contribution amount
      @contribution_amount = Contribution.employer_contribution(@amount, @employer)

      # if the pending contribution + current week's contribution amount is higher than the max contribution, set contribution_amount to the remaining contribution needed to hit the max and set pending to the max amount.
      employer_max_in_cents = @employer.max_contribution * 100
      if !@user.pending_contribution.nil?
        if !@employer.max_contribution.nil? && ((@user.pending_contribution + @contribution_amount) > employer_max_in_cents)
          # set contribution_amount to the remaing amout of the max_contribution
          @contribution_amount = employer_max_in_cents - @user.pending_contribution
        end
        # add contribution_amount to pending_contributions
        @user.pending_contribution += @contribution_amount
      else
        # convert max_contribution to cents
        if !@employer.max_contribution.nil? && (@contribution_amount > employer_max_in_cents)
          # set contribution_amount to the remaing amout of the max_contribution
          @contribution_amount = employer_max_in_cents
        end
        # set pending_contribution to contribution_amount
        @user.pending_contribution = @contribution_amount
      end

      Contribution.add_employer_contribution

      # Check if the date coincides with the contribution frequency
      if Contribution.contribution_due?

        # add pending contribution to the users account_balance
        if !@user.account_balance.nil?
          @user.account_balance += @user.pending_contribution
        else
          @user.account_balance = @user.pending_contribution
        end

        # Add employer contribution amount to the user
        !@user.employer_contribution.nil? ? @user.employer_contribution += @user.pending_contribution : @user.employer_contribution = @user.pending_contribution


        # reset pending contributions
        @user.pending_contribution = nil
      end
    end
  end

  # Increase contribution total to the business
  def self.add_employer_contribution
    # add amount to current_contribution to pull when all round ups are finished
    !@employer.current_contribution.nil? ? @employer.current_contribution += @contribution_amount : @employer.current_contribution = @contribution_amount

    # add amount to total contribution
    !@employer.total_contribution.nil? ? @employer.total_contribution += @contribution_amount : @employer.total_contribution = @contribution_amount

    @employer.save!
  end

  # How much the employer contribution is for the current week
  def self.employer_contribution(amount, employer)
    (amount * employer.match_percent/100).round(2)
  end

  # Check if the max contribution has been met by the employee
  def self.max_contribution_not_met
    @user.pending_contribution.nil? || @employer.max_contribution.nil? || ((@employer.max_contribution * 100) >= @user.pending_contribution)
  end

  # Check if the employer contribution is due on the current round up week
  def self.contribution_due?
    case @employer.frequency
      when 'Weekly'
        # Will always run
        true
      when 'Bi-Monthly'
        # Check if the week is the 1st or 3rd weekend.
         Date.today.week_of_month == 1 || Date.today.week_of_month == 3
      when 'Monthly'
        # Check if it's the first week of the month
        Date.today.first_week?
      when 'Quarterly'
        (Date.today.month == 1 || Date.today.month == 4 || Date.today.month == 7 || Date.today.month == 10) && Date.today.first_week?
      when 'Yearly'
        # Check if current date is past the Employers sign up date (NOTE: change to match frequency_set_date once implemented)
        Date.today.next_year <= @user.created_at
      else
        # If frequency not set, then run add contributions
        true
    end
  end
end
