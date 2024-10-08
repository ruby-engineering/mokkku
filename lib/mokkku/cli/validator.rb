module Mokkku
  module Cli
    module Validator
      ModelsNotProvided = Class.new(StandardError)
      InvalidLlmModel = Class.new(StandardError)
      LlmApiKeyNotProvided = Class.new(StandardError)

      def self.validate_options!(options)
        raise ModelsNotProvided if options.fetch(:models, []).empty?
        raise InvalidLlmModel if options.key?(:llm_model) && !%w[gpt gemini claude].include?(options[:llm_model].to_s.downcase)
        raise LlmApiKeyNotProvided if options[:llm_api_key].to_s == '' && options.key?(:llm_model)
      end
    end
  end
end
