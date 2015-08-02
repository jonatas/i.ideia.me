describe Instatistics do
  let(:media) { load_user_media }
  let(:statistics) { Instatistics.new media }
  let(:statistics_capturing_text) { Instatistics.new media, /(Lorenzo|Filho|Mandala|T[aâ]nia)/i }

  it "receives user media data" do
    expect(statistics.media).to eq(media)
  end

  it "groups your media by tags" do
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
    expect(usage).to have_key(:hours)
    expect(usage).to have_key(:month)
    expect(usage).to have_key(:year)
    expect(usage).to have_key(:week_day)
  end

  it "resumes all things on to_hash method" do
    info = statistics.to_hash
    expect(info).to have_key(:usage)
    expect(info).to have_key(:top_fans)
  end

end
