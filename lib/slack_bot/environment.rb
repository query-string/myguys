class SlackBot
  module Environment
    REGEX = /@([A-Za-z0-9_-]+)/i

    def regex
      REGEX
    end
  end
end
