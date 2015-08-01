describe Instatistics do
  let(:images) { load_user_media_from_fixtures }
  let(:statistics) { Instatistics.new images }
  let(:statistics_capturing_text) { Instatistics.new images, /(Lorenzo|Filho|Mandala|T[aâ]nia)/i }

  it "receives user media data" do
    expect(statistics.images).to eq(images)
  end

  it "groups your images by tags" do
    expect(statistics.tags).to have_key("sunset")
  end

  it "find the top fans" do
    top_fans = statistics.top_fans
    expect(top_fans).to_not be_empty
  end

  it "normalizes interesting text words into tags" do
    expect(statistics.tags).to_not have_key("Lorenzo")
    expect(statistics_capturing_text.tags).to have_key("Lorenzo")
    expect(statistics_capturing_text.tags).to have_key("mandala")
  end

  it "analizes what days and hours you post your pics" do
    frames = statistics.timeframes
    expect(frames).to_not be_empty
    expect(frames).to have_key :hour
    expect(frames).to have_key :week_day
    expect(frames).to have_key :year
  end

  it "counts usage using timeframes" do
    usage = statistics.usage
    p usage
  end

end
