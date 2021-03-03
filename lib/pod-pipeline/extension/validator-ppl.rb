require 'cocoapods'

module Pod
  class Validator
    def xcodebuild(action, scheme, configuration, deployment_target:)
      require 'fourflusher'
      command = %W(clean #{action} -workspace #{File.join(validation_dir, 'App.xcworkspace')} -scheme #{scheme} -configuration #{configuration})
      command += %w(--help)

      if analyze
        command += %w(CLANG_ANALYZER_OUTPUT=html CLANG_ANALYZER_OUTPUT_DIR=analyzer)
      end

      begin
        _xcodebuild(command, true)
      rescue => e
        message = 'Returned an unsuccessful exit code.'
        message += ' You can use `--verbose` for more information.' unless config.verbose?
        error('xcodebuild', message)
        e.message
      end
    end
  end
end