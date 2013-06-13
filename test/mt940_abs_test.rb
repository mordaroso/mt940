require 'helper'

class TestMt940Abs < Test::Unit::TestCase

  def setup
    file_name = File.dirname(__FILE__) + '/fixtures/abs.txt'
    @transactions = MT940::Base.transactions(file_name, MT940::Abs)
    @transaction = @transactions.first
  end

  should 'have the correct number of transactions' do
    assert_equal 8, @transactions.size
  end

  context 'Transaction' do
    should 'have a bank_account' do
      assert_equal '320123456', @transaction.bank_account
    end

    should 'have an amount' do
      assert_equal -308.45, @transaction.amount
    end

    should 'have a currency' do
      assert_equal 'CHF', @transaction.currency
    end

    should 'have a date' do
      assert_equal Date.new(2013,5,8), @transaction.date
    end

    should 'return its bank' do
      assert_equal 'Abs', @transaction.bank
    end

    should 'have a description' do
      assert_equal "Extra Express Transport Logistik AG", @transaction.description
    end

    should 'have a multiline description' do
      description = "Brau- und Rauchshop GmbH,000550128600001215400353889,CHF 35.20\n" \
                    "DPD (Schweiz) AG,230726000002826189233355313,CHF 23.50\n" \
                    "Fracht AG,Faktura-Nr.: 512693,CHF 305.80\n" \
                    "IWB,000020419456001006803440002,CHF 125.35"

      assert_equal description, @transactions[1].description
    end

    should 'have a type' do
      assert_equal "Belast. E-Banking", @transaction.type
    end

  end


end
