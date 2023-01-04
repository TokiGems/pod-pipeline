module PPL
    class Bundle
        def self.cp(inputs, output, include_list=[], exclude_list=[])
            puts "\n目标文件：#{output}\n"

            #获取合并文件的路径序列
            inputs.each do |input|
                puts "\n合并路径：#{input}"

                Dir[input].each do |input_bundle|;
                    #若 input_bundle 为输出目录 则跳过
                    next if input_bundle.eql? output
                    #若 input_file 非被include标记的文件 则跳过
                    is_include = false
                    include_list.each { |include|
                        input_file_basename = File.basename(input_bundle)
                        include_basename = File.basename(include)
                        if input_file_basename == "#{include_basename}.bundle"    
                            is_include = true
                            break
                        end
                    }
                    next unless is_include
                    #若 input_file 为被exclude标记的文件 则跳过
                    is_exclude = false
                    exclude_list.each { |exclude|
                        input_file_basename = File.basename(input_bundle)
                        exclude_basename = File.basename(exclude)
                        if input_file_basename == "#{exclude_basename}.bundle"    
                            is_exclude = true
                            break
                        end
                    }
                    next if is_exclude
                    #合并
                    puts "合并资源包：" + input_bundle
                    FileUtils.cp_r(input_bundle, output, :preserve => true)
                end
            end
        end
    end
end