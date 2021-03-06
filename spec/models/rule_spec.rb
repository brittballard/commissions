require 'spec_helper'

describe Rule do
  it { expect(subject).to belong_to(:applicability_engine) }
  it { expect(subject).to belong_to(:calculation_date_engine) }
  it { expect(subject).to belong_to(:compensation_engine) }
  it { expect(subject).to belong_to(:payment_date_engine) }
  it { expect(subject).to belong_to(:organization) }

  it { expect(subject).to have_many(:commission_schedules) }
  it { expect(subject).to have_many(:deals).through(:commission_schedules) }

  it { expect(subject).to validate_presence_of(:name) }

  describe '#mutable' do
    it 'returns false if the rule is associated with a deal' do
      deal = create(:deal)
      rule = create(:rule)
      rule.deals << deal

      expect(rule.mutable?).to be_false
    end

    it 'returns true if the rule is not associated with a deal' do
      rule = build(:rule, deals: [])

      expect(rule.mutable?).to be_true
    end
  end

  describe '.deactivated' do
    it 'only returns rules that are not active' do
      rule = create(:rule, active: false)
      create(:rule, active: true)

      rules = Rule.deactivated

      expect(rules.length).to eq 1
      expect(rules).to eq [rule]
    end
  end

  describe '.live' do
    it 'only returns rules that have an active flag set to true' do
      rule = create(
        :rule,
        active: true,
        start_date: Time.now - 5.days,
        end_date: Time.now + 5.days
      )
      create(:rule, active: false)

      rules = Rule.live

      expect(rules.length).to eq 1
      expect(rules).to eq [rule]
    end

    it "only returns rules when today's date falls between their start and end" do
      rule = create(
        :rule,
        active: true,
        start_date: Time.now - 5.days,
        end_date: Time.now + 5.days
      )
      create(
        :rule,
        active: true,
        start_date: Time.now - 10.days,
        end_date: Time.now - 5.days
      )

      rules = Rule.live

      expect(rules.length).to eq 1
      expect(rules).to eq [rule]
    end

    it "only returns rules when today's date falls after the start_date if the end_date is nil" do
      rule = create(
        :rule,
        active: true,
        start_date: Time.now - 5.days,
        end_date: nil
      )
      create(
        :rule,
        active: true,
        start_date: Time.now + 10.days,
        end_date: nil
      )

      rules = Rule.live

      expect(rules.length).to eq 1
      expect(rules).to eq [rule]
    end

    it "only returns rules when today's date falls before the end_date if the start_date is nil" do
      rule = create(
        :rule,
        active: true,
        start_date: nil,
        end_date: Time.now + 5.days
      )
      create(
        :rule,
        active: true,
        start_date: nil,
        end_date: Time.now - 5.days
      )

      rules = Rule.live

      expect(rules.length).to eq 1
      expect(rules).to eq [rule]
    end
  end
end
