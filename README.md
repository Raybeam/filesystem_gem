# FilePather (name is temporary!)

## Installation

Add this line to your application's Gemfile:

    gem 'FilePather', :path => 'path/to/FilePather'

And then execute:

    $ bundle

## Supported Filesystems
- S3
- Local
- HTTP (source only)
- Google*
- HDFS*

\* Not yet implemented

## Filepath Format
Paths must be formatted correctly to be understood by FilePather.

S3:

    s3://bucketname/file
    
URL:

    http://www.website.com/file.csv
    

## Usage
The following operations are available:

    FilePather.copy source dest
    
    FilePather.move source dest
    
    FilePather.delete filepath
    
    FilePather.toStream filepath



