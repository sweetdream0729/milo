# ================================================
# RUBY->CONTROLLER->EMPLOYEES-CONTROLLER =========
# ================================================
class EmployeesController < ApplicationController

  # ----------------------------------------------
  # CONCERNS -------------------------------------
  # ----------------------------------------------
  include ActionView::Helpers::NumberHelper
  include SubheaderHelper

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!
  before_action :set_subheader

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    @employees = User.where(business_id: @biz.id).all.order(id: :desc)

    set_employee_data
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
    @employee = User.find(params[:id])
    @employee.business_id = nil
    # skip validations incase there is an issue on the user object (ex: they haven't fully signed up)
    @employee.save(validate: false)

    respond_to do |format|
      format.js
    end
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SET-SUBHEADER --------------------------------
  # ----------------------------------------------
  def set_subheader
    subheader_set :works
  end

  # ----------------------------------------------
  # SET-EMPLOYEE-DATA ----------------------------
  # ----------------------------------------------
  def set_employee_data
    @emp_data = []
    @employees.each do |e|
      emp = {}
      emp['name'] = e.name
      emp['email'] = e.email
      emp['id'] = e.id
      emp['total_contrib'] = set_total_contribution(e)

      transfers = Transfer.where(user_id: e.id)
      if !transfers.empty?
        amount = (transfers.last.roundup_amount.to_f)
        emp['last_contrib'] = Contribution.employer_contribution(amount, @biz)
      end
      @emp_data << emp
    end
  end

  # ----------------------------------------------
  # SET-TRANSFER-AVERAGE -------------------------
  # ----------------------------------------------
  # transfers: All the transfers associated with the user
  # return: The average transfer amount
  def set_transfer_average(transfers)
    all_transfer_amounts = transfers.map {|tr| tr.roundup_amount.to_f }
    all_transfer_average = (all_transfer_amounts.inject{ |sum, el| sum + el }.to_f / all_transfer_amounts.size)
    @transfer_avg = (all_transfer_average > 0) ? number_to_currency(all_transfer_average) : "$0.00"
  end

  # ----------------------------------------------
  # SET-TOTAL-CONTRIBUTION -----------------------
  # ----------------------------------------------
  def set_total_contribution(e)
    if e.employer_contribution
      number_to_currency(e.employer_contribution.round(2) / 100)
    end
  end

end
