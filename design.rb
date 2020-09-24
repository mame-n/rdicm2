require "rdicm"

class ProtoRdicm
  def initialize
    @fname = "US000001"
  end

  def wf1
    Rdicm.open( @fname, "r+b" ) do |dicm|
      dicm.readlines.each_with_index do |line,i|
        puts "No.#{i} VR is #{line["VR"]} : TAG is #{line["TAG"]}"

        if "0008:0005" == line["TAG"]
          puts "HaHaHa  #{line["TAG"]} is #{line["BODY"]}"
        end

#        line.mach_tag( :imageType ) do |size, body|
#          puts "Size is #{size} and body is #{body}"
#        end

      end
    end
  end

  def wf2
    Rdicm.open( @fname, "r+b" ) { |dicm|
      dicm.tags["0008:0005"].each do |ele,v|
        puts "ele=\"#{ele}\" and v=\"#{v}\""
      end
    }
  end

  def wf3
    Rdicm.open( @fname ) { |dicm|
      dicm.tags["0008:0005"].each do |ele|
        puts "ele=\"#{ele}\""
        puts "size is #{ele[0]}"
        puts "size is #{ele["SIZE"]}"
      end
    }
  end

  def wf4
    Rdicm.open( FName ) { |dicm|
      puts dicm.tags["0008:0008"]["BODY"]
      puts dicm.tags("0008:0010")["BODY"]
      
      dicm.tags["0008:0008"]["BODY"].display
      dicm.tags["0008:0008"]["BODY"].dump
    }
  end
end

# tagsはHash
# dicmはIOのファイル、よってreadlinesが使える
# ただし readlinesはオーバーラップさせる
# readlinesの中身は1タグのデータをHashで返すものにしている
# tagsのHashに displayや dumpといったメッソドを付け加えたい
# データの16進ダンプと表示で、表示は中身によって変える
# 画像ならjpg表示、テキストならテキストとか。
# tagsはメソッドでもいいかも。

ProtoRdicm.new.wf2
