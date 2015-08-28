require 'spec_helper'

describe FPS3 do

  before(:all) do
    FPS3.mock_connection
    FPS3.mkdir "rspec"
    @result_1 = {:dir=>"rspec", :file=>"test.txt"}
    @result_2 = {:dir=>"missing", :file=>"test.txt"}
    @result_3 = {:dir=>"rspec", :file=>"test2.txt"}
    @filepath = File.dirname(__FILE__) + "/test_files/test.txt"
  end


  it 'can upload a file' do
    expect{
      FPS3.copy_from_local @result_1, @filepath
      expect(FPS3.connection.directories.get('rspec').files.get('test.txt')).not_to equal(nil)
    }.not_to raise_error(Exception)
  end

  it 'does not upload to missing directory' do
    expect{
      FPS3.copy_from_local @result_2, @filepath
    }.to raise_error(FPS3.directory_error)
  end

  it 'can upload a file and download it' do
    expect{
      FPS3.copy_from_local @result_1, @filepath
      FPS3.copy_to_local @result_1, '/tmp/fps3'
    }.not_to raise_error(Exception)
  end

  it 'can upload from stream' do
    expect{
      file = File.open(@filepath)
      FPS3.copy_from_stream @result_1, file
      expect(FPS3.connection.directories.get('rspec').files.get('test.txt')).not_to equal(nil)
    }.not_to raise_error(Exception)    
  end

  it 'can upload a file and delete it' do
    expect{
      FPS3.copy_from_local @result_1, @filepath
      FPS3.delete @result_1
      expect(FPS3.connection.directories.get('rspec').files.get('test.txt')).to equal(nil)
    }.not_to raise_error(Exception)
  end

  it 'can upload a file and copy it' do
    expect{
      FPS3.copy_from_local @result_1, @filepath
      FPS3.copy_to_self @result_1, @result_3
      expect(FPS3.connection.directories.get('rspec').files.get('test2.txt')).not_to equal(nil)
      }.not_to raise_error(Exception)
  end


end