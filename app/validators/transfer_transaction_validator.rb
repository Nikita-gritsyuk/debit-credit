class TransferTransactionValidator < ActiveModel::Validator
  def validate(record)
    validate_subjects(record)
    validate_sender_balance(record)
    validate_subjects_different(record)
  end

  def validate_subjects(record)
    return true if record.sender || record.receiver

    record.errors.add :base, 'Transfer transaction must have a sender or receiver'
  end

  def validate_sender_balance(record)
    return true if record.sender.nil? || record.sender.balance.to_f >= record.amount.to_f

    record.errors.add :base, 'Sender have no enough balance'
  end

  def validate_subjects_different(record)
    return true if record.sender != record.receiver

    record.errors.add :base, 'Sender and receiver must be different users'
  end
end
