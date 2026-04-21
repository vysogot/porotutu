# frozen_string_literal: true

module SuppressPhlexWarnings
  def warn(message, category: nil)
    return if message.include?('/gems/phlex-')

    super
  end
end

Warning.singleton_class.prepend(SuppressPhlexWarnings)
