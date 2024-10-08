require_relative 'validator'
require_relative 'prompt'
require_relative '../generators/builder'
require_relative '../yaml_sanitizer'

module Mokkku
  module Cli
    class Runner
      def self.start(options = {})
        ::Mokkku::Cli::Validator.validate_options!(options)

        options[:models].each do |model_name|
          columns = Object.const_get(model_name).columns
          prompt = ::Mokkku::Cli::Prompt.generate(model_name, columns, options.fetch(:mocks_count, 10), options.fetch(:language, 'english'))

          if options.key?(:llm_model) && options.key?(:llm_api_key)
            generator = ::Mokkku::Generators::Builder.call(
              generator: options[:llm_model],
              api_key: options[:llm_api_key],
              prompt: prompt
            )

            yaml_mock = generator.call(api_key: options[:llm_api_key], prompt: prompt)
            mock_file_name = model_name.to_s.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase

            puts "Write mocks for #{model_name} model in #{mock_file_name}.yml"
            File.write(
              File.join(options.fetch(:mocks_path, './spec/mocks'), "#{mock_file_name}.yml"),
              ::Mokkku::YamlSanitizer.sanitize(yaml_mock)
            )
          else
            puts "Prompt for #{model_name} model: \n\n#{prompt}"
          end
        end

        puts 'Done!'
      end
    end
  end
end
