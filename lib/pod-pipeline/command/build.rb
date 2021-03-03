require 'fileutils'

require 'pod-pipeline/util/scanner'
require 'pod-pipeline/util/xcodebuild'
require 'pod-pipeline/util/binary'
require 'pod-pipeline/util/bundle'

require 'pod-pipeline/extension/dir-ppl'

module PPL
    class Command
        class Build < Command
            self.summary = '项目构建'
            self.description = <<-DESC
                构建项目代码、资源文件和依赖库，生成Framework包和Bundle包
            DESC
            self.arguments = [
                CLAide::Argument.new('项目根目录（默认使用当前目录）', false),
            ]
            def self.options
                [
                    ['--output=./', '项目构建的输出目录。(默认使用项目根目录)'],
                    ['--configuration=Release', '项目构建的环境。(默认为Release)'],
                    ['--arch=arm64,armv7,x86_64', '项目构建的架构。(默认为 arm64,armv7,x86_64)'],
                    ['--combine=local,pod', '项目构建后合并依赖库的二进制文件，local为本地依赖库，pod为CocoaPods依赖库。(默认为 local)'],
                ].concat(super)
            end

            def initialize(argv)
                @path               = argv.arguments!
                @output             = argv.option('output', '').split(',').first
                @configuration      = argv.option('configuration', '').split(',').first
                @archs              = argv.option('arch', '').split(',')
                @combines           = argv.option('combine', '').split(',')
                
                @projectPath = @path.count.zero? ? Pathname.pwd : @path.first
                @output = @output ? @output : @projectPath

                super
            end

            def run
                PPL::Scanner.new(@projectPath, ["pod", "workspace"]).run
            
                @podspec = PPL::Scanner.podspec
                @workspace = PPL::Scanner.workspace
                puts "Pod: #{@podspec}"
                puts "Workspace: #{@workspace.path}"
                
                #初始化 构建目录
                reset_dir
                
                #构建
                puts "\n[构建 #{@configuration} 环境的 #{@archs.join(", ")} 架构项目]"
                @archs.each do |arch|
                    XCodebuild.build(@workspace.path, @podspec.name, arch, @configuration, @build_path)
                end

                #添加头文件
                puts "\n[添加Framework头文件]"
                add_headers

                #合并二进制文件
                puts "\n[合并 #{@combines.join(", ")} 的二进制文件]"
                combine_binarys(@combines.include?('local'), @combines.include?('pod'))

                #合并资源包
                puts "\n[合并 #{@combines.join(", ")} 的资源包]"
                combine_bundles(@combines.include?('local'), @combines.include?('pod'))

                #拷贝构建内容到Pod目录
                puts "\n[拷贝内容到Pod目录]"
                FileUtils.cp_r(@framework_path, @sdk_path)
                FileUtils.cp_r(@bundle_path, @sdk_path)
            end

            def reset_dir
                #初始化 构建目录
                @build_path = "#{@output}/#{@podspec.name}-#{@podspec.version}"
                Dir.reset(@build_path)
                #初始化 Framework目录
                @framework_path = "#{@build_path}/#{@podspec.name}.framework"
                Dir.reset(@framework_path)
                @framework_headers_path = "#{@framework_path}/Headers"
                Dir.reset(@framework_headers_path)
                #初始化 Bundle目录
                @bundle_path = "#{@build_path}/#{@podspec.name}.bundle"
                Dir.reset(@bundle_path)
                #初始化 SDK目录
                @sdk_path = "#{@output}/#{@podspec.name}/#{@podspec.name}SDK"
                Dir.reset(@sdk_path)
            end
    
            def add_headers
                header_stands = "#{@output}/Example/Pods/Headers/Public/#{@podspec.name}/*.h"
                Dir[header_stands].each do |header_stand|
                    if File.ftype(header_stand).eql? 'link'
                        puts File.basename(header_stand)
    
                        header = "#{File.dirname(header_stand)}/#{File.readlink(header_stand)}"
                        FileUtils.cp(header, @framework_headers_path)
                    end
                end
            end
    
            def combine_binarys(local_dependency, pod_dependency)
                binary = "#{@framework_path}/#{@podspec.name}"
                #添加 构建生成的二进制文件
                inputs = ["#{@build_path}/**/lib#{@podspec.name}.a"]
                if local_dependency
                    #添加 本地依赖的二进制文件
                    inputs << "#{@output}/#{@podspec.name}/Libraries/**/*.a" 
                    inputs << "#{@output}/#{@podspec.name}/Frameworks/**/*.framework/*"
                end
                if pod_dependency
                    #添加 Pod依赖库构建生成的二进制文件
                    inputs << "#{@build_path}/**/lib*.a";
                    #添加 Pod依赖库预先构建的二进制文件
                    inputs << "#{@output}/Example/Pods/**/*SDK/*.framework/*"
                    #添加 Pod依赖库本地依赖的二进制文件
                    inputs << "#{@output}/Example/Pods/**/Libraries/**/*.a"
                    inputs << "#{@output}/Example/Pods/**/Frameworks/**/*.framework/*"
                end
    
                Binary.combine(binary, inputs)
                Binary.thin(binary, @archs)
            end
            
            def combine_bundles(local_dependency, pod_dependency)
                #添加 构建生成的资源包
                inputs = ["${output_directory_path}/**/${POD_NAME}/*.bundle"]
                if local_dependency
                    #添加 本地依赖的资源包
                    inputs << "#{@output}/#{@podspec.name}/Libraries/**/*.bundle" 
                    inputs << "#{@output}/#{@podspec.name}/Frameworks/**/*.bundle"
                end
                if pod_dependency
                    #添加 Pod依赖库构建生成的资源包
                    inputs << "#{@build_path}/**/*.bundle"
                    #添加 Pod依赖库预先构建的资源包
                    inputs << "#{@output}/Example/Pods/**/*SDK/*.bundle"
                    #添加 Pod依赖库本地依赖的资源包
                    inputs << "#{@output}/Example/Pods/**/Libraries/**/*.bundle"
                    inputs << "#{@output}/Example/Pods/**/Frameworks/**/*.bundle"
                end
    
                Bundle.combine(@bundle_path, inputs)
            end
        end
    end
end