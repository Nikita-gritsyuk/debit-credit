class TransferTransactionDecorator < ApplicationDecorator
  delegate_all

  def sender_signature
    sender&.email || 'DebitCredit (incoming transaction)'
  end

  def receiver_signature
    receiver&.email || 'DebitCredit (outgoing transaction)'
  end

  def incoming?
    receiver_id.present? && receiver_id == context[:current_user]&.id
  end

  def outgoing?
    sender_id.present? && sender_id == context[:current_user]&.id
  end

  def formated_amount
    format('%.2f', amount)
  end

  def styled_amount
    if incoming?
      ActionController::Base.helpers.content_tag('p', "+ #{formated_amount} $", class: 'text-success')
    elsif outgoing?
      ActionController::Base.helpers.content_tag('p', "- #{formated_amount} $", class: 'text-danger')
    else
      # This case is not realistic on this stage, but it's for future use
      ActionController::Base.helpers.content_tag('p', "#{formated_amount} $", class: 'text-info')
    end
  end
end
