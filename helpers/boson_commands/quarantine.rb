  # Now let's use this in another library
  module Quarantine
    # A boson callback to specify a library's configuration
    def self.config
      {:dependencies=>['input']}
    end

    # Opens a reddit url in browser. Is it really worth it?
    def reddit(url)
      if ask("Are you sure you want to do this to yourself? (y/N)")
        "ok"
      end
    end
  end

