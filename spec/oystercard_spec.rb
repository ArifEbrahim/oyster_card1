# require './lib/oystercard.rb'

require 'oystercard'

RSpec.describe Oystercard do
  let(:entry_station) {:entry_station} 
  let(:exit_station) {:exit_station} 
  describe "#balance" do
    it "should return the balance on the card" do
      expect(subject.balance).to eq (0)
      expect(subject.journeys).to eq ([])
    end
  end

  describe "#top_up" do
    it 'should add to the balance' do
      expect{ subject.top_up(50) }.to change{ subject.balance }.by (50)
    end
    it 'should error if maximum balace exceeded' do
      subject.top_up(Oystercard::MAXIMUM_BALANCE)
      expect { subject.top_up 1 }.to raise_error "limit exceeded of #{Oystercard::MAXIMUM_BALANCE}"
    end
  end

  describe "#deduct" do
    # it 'should reduce the balance' do
    #   subject.top_up(10)
    #   expect{ subject.deduct(5)}.to change{ subject.balance }.by (-5)
    # end
  end 

  describe '#in_journey?' do
   # let (:station){ double :station }
    describe 'validation for touch in or out' do
      before  do 
        subject.top_up(Oystercard::BALANCE_LIMIT)
        subject.touch_in(entry_station)
      end
            
      it 'should return true after touching in' do
        expect(subject.in_journey?).to eq(true)
      end

      it 'should keep the information of the entry_station' do
        #station = double("Holborn")
        expect(subject.entry_station).to eq(entry_station)
      end
    
      it 'should return false after touching out' do
        subject.touch_out(exit_station)
        expect(subject.in_journey?).to eq(false)
      end
      
      it 'should record the information of both entry & exit station' do
        subject.touch_out(exit_station)
        #expect(subject.exit_station).to eq(exit_station)
          expect(subject.journeys).to eq([{entry: entry_station, exit: exit_station}])
      end

      it 'forget the entry station on touch out' do
        subject.touch_out(exit_station)
        expect(subject.entry_station).to eq(nil)
        expect(subject.exit_station).to eq(nil)
      end

      it 'charges the minimum fare on touch out' do
        expect{ subject.touch_out(exit_station)}.to change{ subject.balance }.by(-Oystercard::MINIMUM_FARE)
      end
    end

    it 'raise an error if user touch_in with 0 balance' do
      expect { subject.touch_in(entry_station) }.to raise_error 'Not enough funds'
    end
  end
end