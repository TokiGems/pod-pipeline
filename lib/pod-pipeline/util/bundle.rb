module PPL
    class Bundle
        def self.combine(output, inputs)
            puts "\n目标文件：#{output}\n"

            #获取合并文件的路径序列
            inputs.each do |input|
                puts "\n合并路径：#{input}"

                Dir[input].each do |input_bundle|;
                    #若 input_bundle 为输出目录 则跳过
                    next if input_bundle.eql? output
                    
                    #合并
                    puts "合并资源包：" + input_bundle
                    FileUtils.cp_r(input_bundle, File.dirname(output), :preserve => true)
                end
            end
        end
    end
end