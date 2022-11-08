module PPL
    class Bundle
        def self.cp(inputs, output, ignore_list=[])
            puts "\n目标文件：#{output}\n"

            #获取合并文件的路径序列
            inputs.each do |input|
                puts "\n合并路径：#{input}"

                Dir[input].each do |input_bundle|;
                    #若 input_bundle 为输出目录 则跳过
                    next if input_bundle.eql? output
                    #若 input_bundle 为被忽略标记的文件 则跳过
                    is_ignore = false
                    ignore_list.each { |ignore|
                        input_file_basename = File.basename(input_bundle)
                        ignore_basename = File.basename(ignore)
                        if input_file_basename == "#{ignore_basename}.bundle"    
                            is_ignore = true
                            break
                        end
                    }
                    next if is_ignore
                    #合并
                    puts "合并资源包：" + input_bundle
                    FileUtils.cp_r(input_bundle, output, :preserve => true)
                end
            end
        end
    end
end