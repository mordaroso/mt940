module MT940

  class Base

    attr_accessor :bank

    def self.transactions(file, bank_klass = nil)
      file  = File.open(file) if file.is_a?(String)
      if file.is_a?(File) || file.is_a?(Tempfile)
        first_line  = file.readline
        second_line = file.readline unless file.eof?
        klass       = bank_klass || determine_bank(first_line, second_line)
        file.rewind
        instance = klass.new(file)
        file.close
        instance.parse
      else
        raise ArgumentError.new('No file is given!')
      end
    end

    def parse
      @tag86 = false
      @lines.each_with_index do |line, index|
        begin
          @line = line
          @line.match(/^:(\d{2}F?):/) ? eval('parse_tag_'+ $1) : parse_line
        rescue Exception => e
          p "Exception at line #{index}: #{line}"
          raise e
        end
      end
      @transactions
    end

    private

    def self.determine_bank(*args)
      Dir.foreach(File.dirname(__FILE__) + '/banks/') do |file|
        if file.match(/\.rb$/)
          klass = eval(file.gsub(/\.rb$/,'').capitalize)
          bank  = klass.determine_bank(*args)
          return bank if bank
        end
      end
      self
    end

    def initialize(file)
      @transactions = []
      @bank  = self.class.to_s.split('::').last
      @bank  = 'Unknown' if @bank == 'Base'
      @lines = file.readlines
    end

    def parse_tag_25
      @line.gsub!('.','')
      if @line.match(/^:\d{2}:[^\d]*(\d*)/)
        @bank_account = $1.gsub(/^0/,'')
        @tag86 = false
      end
    end

    def parse_tag_60F
      @currency = @line[12..14]
    end

    def parse_tag_61(pattern = nil)
      pattern = pattern || /^:61:(\d{6})(C|D)(\d+),(\d{0,2})/
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
        @transaction.description = $1.gsub(/>\d{2}/,'').strip
        parse_contra_account
      end
    end

    def parse_line
      if @tag86 && @transaction.description
        @transaction.description.lstrip!
        @transaction.description += ' ' + @line.gsub(/\n/,'').gsub(/>\d{2}\s*/,'').gsub(/\-XXX/,'').gsub(/-$/,'').strip
        @transaction.description.strip!
      end
    end

    def parse_date(string)
      Date.new(2000 + string[0..1].to_i, string[2..3].to_i, string[4..5].to_i) if string
    end

    def parse_contra_account
    end

    #Fail silently
    def method_missing(*args)
    end

  end

end
