require 'spec_helper'

describe Tacokit::Client::Actions do
  def test_action_id
    '548e3153ea7ca8f9cd3cb77b'
  end

  describe "#action", :vcr do
    it "returns a token authorized action" do
      action = app_client.action(test_action_id)

      expect(action.type).to be_present
      expect(action.data).to be_any
    end

    it 'returns oauth authorized board' do
      action = oauth_client.action(test_action_id)

      expect(action.type).to be_present
      expect(action.data).to be_any
    end
  end

  describe "#action_field", :vcr do
    it "returns a value" do
      field = app_client.action_field(test_action_id, :type)

      expect(field['_value']).to be_present
    end

    it "returns a hash" do
      field = app_client.action_field(test_action_id, :data)

      expect(field).to be_a(Hash)
    end
  end

  describe "#action_resource", :vcr do
    it "returns action entities" do
      entities = app_client.action_resource(test_action_id, :entities)

      expect(entities).to be_any
    end

    it "returns action board" do
      board = app_client.action_resource(test_action_id, :board)

      expect(board.name).to be_present
    end
  end

  describe "#update_action", :vcr do
    def test_editable_action_id
      '549102431b607566bafc93a9'
    end

    it "updates a action" do
      action = app_client.update_action(test_editable_action_id, text: "@tacokit Thanks for the invite, bud")

      expect(action.data.text).to eq "@tacokit Thanks for the invite, bud"
    end
  end
end
