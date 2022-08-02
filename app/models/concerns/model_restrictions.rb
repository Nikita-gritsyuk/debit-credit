require 'active_support/concern'

module ModelRestrictions
  extend ActiveSupport::Concern

  class_methods do
    def restrict_destroy
      before_destroy do
        raise ActiveRecord::ActiveRecordError, "#{self.class.name} can not be destroyed"
      end
    end

    def restrict_update
      before_update do
        raise ActiveRecord::ActiveRecordError, "#{self.class.name} can not be updated" if changed?
      end
    end
  end
end
