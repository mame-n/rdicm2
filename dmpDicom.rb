#!C:\Program\ Files\ruby-1.8\bin\ruby.exe

require './rdicm2'

class DmpDicom
  def initialize
    @CONF = {}
    @CONF[:ASCII_DISP] = true
  end

  def parse_opts
    while opt = ARGV.shift
      case opt
      when "-x"
        @CONF[:HEX_DISP] = true
        @CONF[:ASCII_DISP] = false
      when "-a"
        @CONF[:HEX_DISP] = false
        @CONF[:ASCII_DISP] = true
      when "-q"
        @CONF[:HEX_DISP] = false
        @CONF[:ASCII_DISP] = false
      when "-h"
        print_usage
        exit 0
      when /^-/
        puts "unrecognized switch #{opt}"
        print_usage
        exit 0
      else
        @CONF[:DICOM_NAME] = opt
      end
    end

    unless @CONF[:DICOM_NAME]
      print_usage
      exit 0 
    end
  end

  def main
    parse_opts

    rdc = Rdicm.new(@CONF[:DICOM_NAME])
    rdc.printHeader
  end

  def print_usage
    help_str =<<EOF
Usage:  dumpDicom.rb [options] [DICOM file]
  -a	Display data body with ASCII if possible
  -x	Display data body with hex deximal
EOF
    puts help_str
  end
end

if __FILE__ == $0
  DmpDicom.new.main
end
