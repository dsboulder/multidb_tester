module MultidbTester
  module Utilities
    def self.connection_specs
      ActiveRecord::Base.configurations.reject { |spec_name, config|
        spec_name != "test" && !spec_name.starts_with?("test_multidb_")
      }
    end
  end
end