require 'spec_helper'

describe Tacokit::Client::Boards do
  def test_board_link
    'swezQ9XS'
  end

  def test_board_id
    '548a675581d1d669c9e8184e'
  end

  describe "#board", :vcr do
    it "returns a token authorized board" do
      board = app_client.board(test_board_link)

      expect(board.name).to eq('Test Board')
    end

    it 'returns oauth authorized board' do
      board = oauth_client.board(test_board_link)

      expect(board.name).to eq('Test Board')
    end
  end

  describe "#board_field", :vcr do
    it "returns a value" do
      name = app_client.board_field(test_board_link, :name)

      expect(name['_value']).to eq('Test Board')
    end

    it "returns an array" do
      power_ups = app_client.board_field(test_board_link, :power_ups)

      expect(power_ups).to eq([])
    end

    it "returns a hash" do
      label_names = app_client.board_field(test_board_link, :label_names)

      expect(label_names).to include("green", "yellow", "orange")
    end
  end

  describe "#board_resource", :vcr do
    it "returns board actions" do
      actions = app_client.board_resource(test_board_link, :actions)

      expect(actions).not_to be_empty

      action = actions.first
      expect(action.member_creator.full_name).to be_present
    end

    it "returns board members" do
      members = app_client.board_resource(test_board_link, :members)

      expect(members).not_to be_empty

      member = members.first
      expect(member.username).to be_present
    end

    it "returns board cards" do
      cards = app_client.board_resource(test_board_link, :cards)

      expect(cards).not_to be_empty

      card = cards.first
      expect(card.pos).to be_present
    end
  end

  describe "#update_board", :vcr do
    it "updates a board" do
      board = app_client.update_board(test_board_id, desc: 'This board is for Tacokit testing')

      expect(board.desc).to eq 'This board is for Tacokit testing'
      assert_requested :put, trello_url_template("boards/#{test_board_id}{?key,token}")
    end

    it "updates nested resource" do
      board = app_client.update_board(test_board_id, label_names: { blue: 'Blue Label' })

      expect(board.label_names).to include 'blue' => 'Blue Label'
    end
  end
end
