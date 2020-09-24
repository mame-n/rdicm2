class Rdicm
  def initialize( fpath )
    @tsize = -1
    open(fpath,"rb") do |fp|
      fp.seek( 132 )  # Skip top 128byte and "DICM" string.
      @mydicom = readDicom(fp)
    end
  end
  attr_accessor :mydicom

  def readDicom(fp)
    mydicom = {:header=>nil, :body=>nil, :next=>nil, :under=>nil}
    header = {:tag=>nil, :vr=>nil, :size=>nil}
    begin
      return nil if @tsize == 0
      header[:tag] = fp.read( 4 ).unpack('S2')
#      printf " *** %04X:%04X\n", header[:tag][0], header[:tag][1]
    rescue
      return nil
    end

    header[:vr] = fp.read( 2 )

    if /OB/ =~ header[:vr] || /SQ/ =~ header[:vr] || /OW/ =~ header[:vr]
      fp.read(2)
      header[:size] = fp.read(4).unpack("L")[0].to_i
      sizesize = 6
    else
      header[:size] = fp.read(2).unpack("S")[0].to_i
      sizesize = 2
    end

    @tsize -= 4 + 2 + sizesize + header[:size]

    mydicom[:header] = header
    if header[:tag][0] == 0x0018 && header[:tag][1] == 0x6011
      fp.read(4)
      @tsize = fp.read(4).unpack("L")[0].to_i
      mydicom[:under] = readDicom(fp)
      @tsize = -1
    else
      mydicom[:body] = fp.read( header[:size] )
    end
    mydicom[:next] = readDicom(fp)

    return mydicom
  end

  def printHeader
    @nest = 0
    printHeaderEach(@mydicom)
  end

  def printHeaderEach(md)
    nestspace = ""
    0.upto(@nest) {nestspace += " "}
    return if md == nil
    printf "%s(%04X:%04X) %s %d\n", nestspace, md[:header][:tag][0], md[:header][:tag][1], md[:header][:vr], md[:header][:size]

    if md[:under]
      @nest += 4
      printHeaderEach(md[:under])
      @nest -= 4
    end
    printHeaderEach(md[:next]) if md[:next]
  end

  def condEncRegulation
#
# refer to "http://otndnld.oracle.co.jp/document/products/oracle10g/102/doc_cd/appdev.102/B19253-01/ap_dicmrls.htm"
#
    while readTag != [0x0002,0x0010]
      nextTag
    end
    vr,size = readHeader
#    body = dataBody(size).split(".")
    common = "1.2.840.10008.1.2."

#    0.upto(common.size) do |i|
#      if common[i] != body[i]
#        return "Error!!"
#      end
#    end

    p "#{common.size} => #{size}"
    if common.size == size
      return "Implicit VR Little Endian Default Transfer Syntax"
    elsif common.size + 1 == size
      case body[size-1]
      when "1"; return "Explicit VR Little Endian Transfer Syntax"
      when "2"; return "Explicit VR Little Endian Transfer Syntax"
      when "5"; return "RLE Lossless"
      else
        return "Size-1 ELSE"
      end
    elsif common.size + 2 == size
      if body[size-2] == "1"
        if body[size-1] == "99"
          return "Deflated Explicit VR Little Endian"
        else
          return "Size-2 size-2=1  ELSE"
        end
      elsif body[size-2] == "4"
        case body[size-1]
        when "50"; return "JPEG Baseline (Process 1)"
        when "51"; return "JPEG Extended (Process 2 & 4) "
        when "52"; return "JPEG Extended (Process 3 & 5) (Retired)"
        when "53"; return "JPEG Spectral Selection, Non-Hierarchical (Process 6 & 8) (Retired) "
        when "100";return "MPEG2 Main Profile @ Main Level"
        else
          return "Size-2 size-2=4  ELSE"
        end
      else
        return "Size-2 ELSE"
      end
    else
      return "ElseElse"
    end

  end

  def isImplicitVR?

  end

  def bodyText?(vr)
    if /UI|TI|LO|CS|LT|SH|AE|TM|DA|PN/ =~ vr
      true
    else
      false
    end
  end


end
