module PPL
    class Binary
        def self.combine(output, inputs, include_list=[], exclude_list=[])
            puts "\n目标文件：#{output}\n"

            #获取合并文件的路径序列
            input_file_queue=""
            inputs.each do |input|
                puts "\n合并路径：#{input}"

                Dir[input].each do |input_file|
                    #若 input_file 为目录 则跳过
                    next if Dir.exists? input_file
                    #若 input_file 为非二进制文件 则跳过
                    info_log = `lipo -info "#{input_file}" > /dev/null 2>&1
                    echo result:$?`
                    next unless info_log.include? 'result:0'
                    #若 input_file 非被include标记的文件 则跳过
                    unless include_list.empty?
                        is_include = false
                        include_list.each { |include|
                            input_file_basename = File.basename(input_file)
                            include_basename = File.basename(include)
                            if input_file_basename == include_basename || input_file_basename == "lib#{include_basename}.a"
                                is_include = true
                                break
                            end
                        }
                        next unless is_include
                    end
                    #若 input_file 为被exclude标记的文件 则跳过
                    unless exclude_list.empty?
                        is_exclude = false
                        exclude_list.each { |exclude|
                            input_file_basename = File.basename(input_file)
                            exclude_basename = File.basename(exclude)
                            if input_file_basename == exclude_basename || input_file_basename == "lib#{exclude_basename}.a"
                                is_exclude = true
                                break
                            end
                        }
                        next if is_exclude
                    end
                    #若 input_file 为序列中已存在的文件 则跳过
                    next if input_file_queue.include? input_file

                    #合并
                    puts "=> #{input_file}"
                    input_file_queue += " \"#{input_file}\""
                end
            end

            #若合并文件序列不为空，执行合并
            unless input_file_queue.empty?
                if File.exists? output
                    output_temp = output+'.temp'
                    File.rename(output, output_temp)

                    combine_log = 
                    `libtool -static -o "#{output}" "#{output_temp}" #{input_file_queue} > /dev/null 2>&1
                    echo result:$?`
                    raise "\ncombine log:\n#{combine_log}" unless combine_log.include? 'result:0'
                    
                    File.delete(output_temp)
                else
                    combine_log = 
                    `libtool -static -o "#{output}" #{input_file_queue} > /dev/null 2>&1
                    echo result:$?`
                    raise "\ncombine log:\n#{combine_log}" unless combine_log.include? 'result:0'
                end
            end 
        end

        def self.thin(binary, archs)
            archs.each do |arch|
                thin_log = 
                `lipo "#{binary}" -thin #{arch} -output "#{binary}-#{arch}" > /dev/null 2>&1
                echo result:$?`
                unless thin_log.include? 'result:0'
                    puts "lipo #{binary} -thin #{arch} 异常"
                    return 
                end
            end
            File.delete(binary)

            binary_pieces = "#{binary}-*"
            combine(binary, [binary_pieces])
            
            Dir[binary_pieces].each do |binary_piece|
                File.delete(binary_piece)
            end
        end
    end
end