module PPL
    class Binary
        def self.combine(output, inputs, ignore="")
            puts "\n目标文件：#{output}\n"

            #获取合并文件的路径序列
            input_file_queue=""
            inputs.each do |input|
                puts "\n合并路径：#{input}"

                Dir[input].each do |input_file|;
                    #若 input_file 为目录 则跳过
                    next if Dir.exists? input_file
                    #若 input_file 为被忽略标记的文件 则跳过
                    unless ignore.empty?
                        next if File.basename(input_file).include? File.basename(ignore) 
                    end
                    #若 input_file 为非二进制文件 则跳过
                    binary_check = `lipo -info "#{input_file}" > /dev/null 2>&1;echo $?`
                    next unless binary_check.include? "0"
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
                    `libtool -static -o "#{output}" "#{output_temp}" #{input_file_queue}
                    echo result:$?`
                    raise "\ncombine log:\n#{combine_log}" unless combine_log.include? 'result:0'
                    
                    File.delete(output_temp)
                else
                    combine_log = 
                    `libtool -static -o "#{output}" #{input_file_queue}
                    echo result:$?`
                    raise "\ncombine log:\n#{combine_log}" unless combine_log.include? 'result:0'
                end
            end 
        end

        def self.thin(binary, archs)
            archs.each do |arch|
                combine_log = 
                `lipo "#{binary}" -thin #{arch} -output "#{binary}-#{arch}"
                echo result:$?`
                unless combine_log.include? 'result:0'
                    puts "lipo -thin 异常"
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