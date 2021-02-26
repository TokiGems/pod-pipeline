module PPL
    class XCodebuild
        def self.build(workspace, scheme, arch, configuration, output)
            puts "Building #{arch} ..."

            sdk = 
            case
            when arch.include?("arm") then 'iphoneos'
            when arch.include?("86") then 'iphonesimulator'
            else raise "暂时不支持 #{arch} 架构" unless sdk
            end

            build_log = 
            `xcodebuild\
            -workspace "#{workspace}"\
            -scheme #{scheme}\
            -sdk #{sdk}\
            -arch #{arch}\
            -configuration #{configuration}\
            -UseModernBuildSystem=NO\
            -quiet\
            MACH_O_TYPE=staticlib\
            BUILD_DIR="#{output}/#{arch}"
            echo result:$?`
            raise "\nbuild log:\n#{build_log}" unless build_log.include? 'result:0'
        end
    end
end