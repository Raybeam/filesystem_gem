require 'spec_helper'

describe FilePather do


  it 'can parse an S3 path' do
    result = FilePather::parse_path("S3://bucketname/file.txt")
    expect(result[:type]).to equal(:S3)
    expect(result[:dir]).to eq("bucketname")
    expect(result[:file]).to eq("file.txt")
  end

  it 'can detect invalid S3 path (only bucket)' do
    expect {
      result = FilePather::parse_path("S3://onlybucket")
    }.to raise_exception("Invalid S3 Path")
  end

  it 'can detect S3 path with missing body' do
    expect {
      result = FilePather::parse_path("S3://")
    }.to raise_exception("Missing Path Body")
  end

  it 'can detect path with unknown prefix' do
    expect {
      result = FilePather::parse_path("abcdefg://1234")
    }.to raise_exception("Unknown Path Prefix")
  end

  it 'can detect local path' do
    result = FilePather::parse_path("/path/to/file.txt")
    expect(result[:path]).to eq("/path/to/file.txt")
    expect(result[:type]).to equal(:local)
  end


end