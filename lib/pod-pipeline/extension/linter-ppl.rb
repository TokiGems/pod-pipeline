module Pod
    class Specification
        class Linter
            def write_to_file(property, value)
                puts "[写入 #{property} = #{value}]"
                file_content = File.read file
                file_content.gsub!(/(.*.#{property}.*=.*)('.*')/,"\\1'#{value}'")
                File.open(file, "w") { |f|
                    f.puts file_content
                }
            end
        end
    end
end