require 'rails_helper'

PushEvent
User

describe StorePhoto do
  let(:filename) { 'foo/bar/test.jpg' }
  let(:s3_url) { "http://higuysio.secchio/#{filename}?foo=1&bar" }
  let(:command) { described_class.new(user, s3_url) }
  let(:user) { create(:guest, :with_wall) }

  it "takes the s3_url" do
    expect(command.s3_url).to eq s3_url
  end

  it "takes the user" do
    expect(command.user).to eq user
  end

  describe "#execute" do
    let(:pusher) do
      class_double("PushEvent").as_stubbed_const
    end

    before do
      allow(pusher).to receive(:execute)
    end

    context 'if the user has no associated walls' do
      let(:user) { create(:guest) }

      it 'raises InvalidInputException' do
        expect { command.execute }.to raise_error StorePhoto::InvalidInputException
      end
    end

    context 'if the url is not valid' do
      let(:s3_url) { 'http://foo.bar/' }

      before do
        stub_const 'ENV', {'S3_BUCKET_NAME' => 'higuysio'}
      end

      it 'raises InvalidInputException' do
        expect { command.execute }.to raise_error StorePhoto::InvalidInputException
      end
    end

    context "if an image with the same path already exists" do
      let(:image) { create(:image, image_path: filename) }

      before { image }

      it 'raises InvalidInputException' do
        expect { command.execute }.to raise_error StorePhoto::InvalidInputException
      end
    end

    context 'when all data is ok' do
      before do
        @result = command.execute
      end


      it 'creates an image entry on the database' do
        expect(@result).to be_a Image
        expect(@result).to be_persisted
        expect(@result.image_path).to eq filename
      end

      it 'sets the last_image' do
        expect(user.reload.last_image).to_not be_nil
      end

      it 'pushes a "photo" event' do
        expect(pusher).to have_received(:execute)
          .with(user.wall, 'photo', user_id: user.id)
      end
    end
  end
end

