class SlackBot
  class SlashFilter < Filter
    def proper_target_defined?
      false
    end
  end
end
