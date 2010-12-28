require "iconv"
module QQWry
  module QQWryIO
    def get_le32
      arr = read(4).unpack("C4")
      arr[0] | arr[1]<<8 | arr[2]<<16 | arr[3]<<24
    end

    def get_le24
      arr = read(3).unpack("C3")
      arr[0] | arr[1]<<8 | arr[2]<<16
    end

    def get_string
      str = ""
      while ((ch = read(1).unpack("a")[0]) != "\x00")
        str += ch
      end
      str
    end

    def get_u8
      read(1).unpack("C")[0]
    end
  end

  module QQWryIpStr
    def ip_str
      [@ip].pack("L").unpack("C4").reverse.join(".")
    end
  end

  class QQWryHeader
    def initialize(file)
      file.seek(0)
      @first = file.get_le32
      @last = file.get_le32
    end
    attr_reader :first, :last
  end

  class QQWryRecord
    include QQWryIpStr

    def initialize(file, pos)
      file.seek(pos)
      @ip = file.get_le32
      case file.get_u8
      when 0x1
        file.seek(pos = file.get_le24)
        case file.get_u8
        when 0x2
          file.seek(file.get_le24)
          @country = file.get_string
          file.seek(pos + 4)
        else
          file.seek(-1, IO::SEEK_CUR)
          @country = file.get_string
        end
        parse_area(file)
      when 0x2
        pos = file.get_le24
        parse_area(file)
        file.seek(pos)
        @country = file.get_string
      else
        file.seek(-1, IO::SEEK_CUR)
        @country = file.get_string
        parse_area(file)
      end
    end
    attr_reader :ip
    def country
      Iconv.iconv("UTF-8", "GBK", @country)
    end

    def area
      Iconv.iconv("UTF-8", "GBK", @area)
    end
    def parse_area(file)
      case file.get_u8
      when 0x2
        if ((pos = file.get_le24) != 0)
          file.seek(pos)
          @area = file.get_string
        else
          @area = ""
        end
      else
        file.seek(-1, IO::SEEK_CUR)
        @area = file.get_string
      end
    end
    private :parse_area
  end

  class QQWryIndex
    include QQWryIpStr

    def initialize(file, pos)
      file.seek(pos)
      @ip = file.get_le32
      @pos = file.get_le24
    end
    attr_reader :ip, :pos
  end

  class QQWryFile
    def initialize(filename = "#{Rails.root.to_s}/vendor/plugins/ruby-qqwry/lib/qqwry.dat")
      @filename = filename
    end

    def each
      File.open(@filename) do |file|
        file.extend QQWryIO
        header = QQWryHeader.new(file)
        pos = header.first
        while pos <= header.last
          index = QQWryIndex.new(file, pos)
          record = QQWryRecord.new(file, index.pos)
          if block_given?
            yield index, record
          else
            puts "#{index.ip_str}-#{record.ip_str} #{record.country}" +
                 " #{record.area}"
          end
          pos += 7
        end
      end
    end

    def find(ip)
      if ip.class == String
        ip = ip.split(".").collect{|x| x.to_i}.pack("C4").unpack("N")[0]
      end

      File.open(@filename) do |file|
        file.extend QQWryIO
        header = QQWryHeader.new(file)
        first = header.first
        left = 0
        right = (header.last - first) / 7
        while left <= right
          middle = (left + right) / 2
          middle_index = QQWryIndex.new(file, first + middle * 7)
          if (ip > middle_index.ip)
            left = middle + 1
          elsif (ip < middle_index.ip)
            right = middle - 1
          else
            return QQWryRecord.new(file, middle_index.pos)
          end
        end
        index = QQWryIndex.new(file, first + right * 7)
        return QQWryRecord.new(file, index.pos)
      end
    end
  end
end
