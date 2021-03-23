require 'claide'

module PPL
    class Command < CLAide::Command
        require 'pod-pipeline/command/new'
        require 'pod-pipeline/command/scan'
        require 'pod-pipeline/command/build'
        require 'pod-pipeline/command/update'
        require 'pod-pipeline/command/publish'

        self.abstract_command = true
        self.command = 'ppl'
        self.description = 'Pod-Pipeline 是 CocoaPods 的流水线工具.'
        
        def self.options
            [
              ['--help', '展示改命令的介绍面板'],
            ]
        end

        def self.options_extension
            options = Array.new
            options_extension_hash.each { |_key, _options_extension|
                _options_extension.each { |_option_extension| 
                  options << [_option_extension.first.gsub(/(--)(.*)/,"\\1#{_key}-\\2"), _option_extension.last]
                } 
            }
            options
        end

        def self.options_extension_hash
            Hash[
              
            ]
        end

        def self.run(argv)
            ensure_not_root_or_allowed! argv
            verify_minimum_git_version!
            verify_xcode_license_approved!
      
            super(argv)
        end

        #
        # 确保root用户
        #
        # @return [void]
        #
        def self.ensure_not_root_or_allowed!(argv, uid = Process.uid, is_windows = Gem.win_platform?)
            root_allowed = argv.include?('--allow-root') || !ENV['COCOAPODS_ALLOW_ROOT'].nil?
            help! 'You cannot run Pod-Pipeline as root.' unless root_allowed || uid != 0 || is_windows
        end
  
        # 读取Git版本号，返回一个新的 {Gem::Version} 实例
        #
        # @return [Gem::Version]
        #
        def self.git_version
            raw_version = `git version`
            unless match = raw_version.scan(/\d+\.\d+\.\d+/).first
                raise "Failed to extract git version from `git --version` (#{raw_version.inspect})"
            end
            Gem::Version.new(match)
        end
  
        # 检查Git版本号是否低于 1.8.5
        #
        # @raise Git版本号低于 1.8.5
        #
        # @return [void]
        #
        def self.verify_minimum_git_version!
            if git_version < Gem::Version.new('1.8.5')
                raise 'You need at least git version 1.8.5 to use Pod-Pipeline'
            end
        end

        #
        # 检查xcode许可是否被批准
        #
        # @return [void]
        #
        def self.verify_xcode_license_approved!
            if `/usr/bin/xcrun clang 2>&1` =~ /license/ && !$?.success?
              raise 'You have not agreed to the Xcode license, which ' \
                'you must do to use CocoaPods. Agree to the license by running: ' \
                '`xcodebuild -license`.'
            end
        end

        def initialize(argv)
            @argv_extension = Hash.new
            self.class.options_extension_hash.each_key { |key|
                @argv_extension[key] = Array.new
                self.class.options.each do |option|
                    name = option.first
                    if name.include?(key)
                        is_option = name.include? '='
                        if is_option
                            option = name.gsub(/(--)(.*)(=.*)/,"\\2")
                            value = argv.option(option, '')
                            @argv_extension[key] << name.gsub(/(--.*=)(.*)/,"\\1#{value}").gsub("#{key}-",'') unless value.empty?
                        else
                            flag = name.gsub(/(--)(.*)/,'\\2')
                            value = argv.flag?(flag)
                            @argv_extension[key] << name.gsub("#{key}-",'') if value
                        end
                    end
                end
            }

            super
        end

        def argv_extension
            @argv_extension 
        end
    end
end