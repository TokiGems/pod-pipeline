require 'cocoapods'
require 'cocoapods-core'

require 'pod/command/trunk'

require 'pod-pipeline/util/scanner'

require 'pod-pipeline/extension/version-ppl.rb'
require 'pod-pipeline/extension/linter-ppl'
require 'pod-pipeline/extension/validator-ppl'

module PPL
    class Command
        class Update < Command
            self.summary = '项目更新'
            self.description = <<-DESC
                更新项目内容
            DESC
            self.arguments = [
                CLAide::Argument.new('项目根目录（默认使用当前目录）', false),
            ]
            def self.options
                [
                    ['--channel=version,git', '更新内容，version为更新podspec文件中的的版本号，git为Git仓库添加对应podspec版本号的tag，并上传到远端。（默认更新所有内容）'],
                    ['--version=x.x.x', '新版本号。（默认使用patch+1）']
                ].concat(super)
            end

            def initialize(argv)
                @path                   = argv.arguments!
                @channels               = argv.option('channel', '').split(',')
                @new_version                = argv.option('version', '').split(',').first
                
                @projectPath = @path.count.zero? ? Pathname.pwd.to_s : @path.first
                @is_master = false
                unless @repo
                    @repo = 'master'
                    @is_master = true
                end

                super
            end

            def run
                PPL::Scanner.new(@projectPath, ['all']).run

                @channels = ["all"] if @channels.count.zero?
            
                puts "\n[更新 #{@channels.join(", ")} 内容]"

                @channels.each do |channel|
                    case channel
                    when "all"
                        update_version
                        update_git
                    when "version"
                        update_version
                    when "git"
                        update_git
                    else
                        raise "暂不支持#{channel}内容扫描"
                    end
                end
            end

            def update_version
                version = PPL::Scanner.linter.spec.version
                raise "版本号异常，无法更新" unless version
                if @new_version
                    version.archiving(@new_version)
                else
                    version.increase_patch 
                end

                PPL::Scanner.linter.write_to_file('version', version.version)
            end

            def update_git
                git = PPL::Scanner.git
                new_tag = PPL::Scanner.linter.spec.version.version
                git.tags.each do |tag|
                    raise "当前版本 #{new_tag} 已发布，请尝试其他版本号" if tag.name.eql? new_tag
                end
                git.add('.')
                git.commit_all(new_tag)
                git.add_tag(new_tag)

                puts "[Git 上传 #{git.remote} #{git.branches.current.first} #{new_tag}]"
                git.push(git.remote, git.branches.current.first, true)
            end
        end
    end
end