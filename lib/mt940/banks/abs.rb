class MT940::Abs < MT940::Base

  def self.determine_bank(*args)
    self if args[0].match(/9518/)
  end

  def parse_tag_61(pattern = nil)
    pattern = pattern || /^:61:(\d+)\d{4}(C|D)(\d+),(\d{0,2})/
    if @line.match(pattern)
      type = $2 == 'D' ? -1 : 1
      @transaction = MT940::Transaction.new(:bank_account => @bank_account, :amount => type * ($3 + '.' + $4).to_f, :bank => @bank, :currency => @currency)
      @transaction.date = parse_date($1)
      @transactions << @transaction
      @tag86 = false
    end
  end

  def parse_tag_86
    if !@tag86 && @line.match(/^:86:\s?(.*)$/)
      @tag86 = true
      @transaction.type = $1.gsub(/>\d{2}/,'').strip
    end
  end

  def parse_line
    if @tag86
      @transaction.description ||= ''
      @transaction.description.lstrip!
      @transaction.description += @line.gsub(/\n/,'').gsub(/>\d{2}\s*/,'').gsub(/\-XXX/,'').gsub(/-$/,'').strip
      @transaction.description.strip!
      @transaction.description.gsub!(/--/, "\n")
    end
  end

end