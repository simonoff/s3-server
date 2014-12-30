require 'builder'
require 'time'

module XmlAdapter
  class << self
    def buckets(bucket_objects)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.ListAllMyBucketsResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |lam|
          lam.Owner do |owner|
            owner.ID('123')
            owner.DisplayName('S3-server')
          end
          lam.Buckets do |buckets|
            bucket_objects.each do |bucket|
              buckets.Bucket do |b|
                b.Name(bucket.name)
                b.CreationDate(bucket.created_at)
              end
            end
          end
        end
      end
    end

    def error(error)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.Error do |err|
          err.Code(error.code)
          err.Message(error.message)
          err.Resource(error.resource)
          err.RequestId(1)
        end
      end
    end

    # <?xml version="1.0" encoding="UTF-8"?>
    # <Error>
    #  <Code>NoSuchKey</Code>
    #  <Message>The resource you requested does not exist</Message>
    #  <Resource>/mybucket/myfoto.jpg</Resource>
    #  <RequestId>4442587FB7D0A2F9</RequestId>
    # </Error>
    #
    def error_no_such_bucket(name)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.Error do |err|
          err.Code('NoSuchBucket')
          err.Message('The resource you requested does not exist')
          err.Resource(name)
          err.RequestId(1)
        end
      end
    end

    def error_bucket_not_empty(name)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct(:xml, version: '1.0', encoding: 'UTF-8')
        xml.Error do |err|
          err.Code('BucketNotEmpty')
          err.Message('The bucket you tried to delete is not empty.')
          err.Resource(name)
          err.RequestId(1)
        end
      end
    end

    def error_no_such_key(name)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.Error do |err|
          err.Code('NoSuchKey')
          err.Message('The specified key does not exist')
          err.Key(name)
          err.RequestId(1)
          err.HostId(2)
        end
      end
    end

    def s3_multipart_initialization(s3_object)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.InitiateMultipartUploadResult(
          xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |imur|
          imur.Bucket(s3_object.bucket.name)
          imur.Key(s3_object.key)
          imur.UploadId(s3_object.id.to_s)
        end
      end
    end

    def s3_multipart_completion(endpoint, s3_object)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.CompleteMultipartUploadResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |pr|
          pr.Location("http://#{endpoint}" \
                      "/#{s3_object.bucket.name}/#{s3_object.key}")
          pr.Bucket(s3_object.bucket.name)
          pr.Key(s3_object.key)
          pr.ETag(s3_object.md5)
        end
      end
    end

    def uploaded_object(endpoint, s3_object)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.PostResponse(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |pr|
          pr.Location("http://#{endpoint}" \
                      "/#{s3_object.bucket.name}/#{s3_object.key}")
          pr.Bucket(s3_object.bucket.name)
          pr.Key(s3_object.key)
          pr.ETag(s3_object.md5)
        end
      end
    end

    def created_bucket(bucket)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.CreateBucketResponse(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |cbr1|
          cbr1.CreateBucketResponse do |cbr2|
            cbr2.Bucket(bucket.name)
          end
        end
      end
    end

    def bucket(bucket)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.ListBucketResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |lbr|
          lbr.Name(bucket.name)
          lbr.Prefix
          lbr.Marker
          lbr.MaxKeys(1000)
          lbr.IsTruncated(false)
        end
      end
    end

    # A bucket query gives back the bucket along with contents
    # <Contents>
    #  <Key>Nelson</Key>
    #  <LastModified>2006-01-01T12:00:00.000Z</LastModified>
    #  <ETag>&quot;828ef3fdfa96f00ad9f27c383fc9ac7f&quot;</ETag>
    #  <Size>5</Size>
    #  <StorageClass>STANDARD</StorageClass>
    #  <Owner>
    #   <ID>bcaf161ca5fb16fd081034f</ID>
    #   <DisplayName>webfile</DisplayName>
    #  </Owner>
    # </Contents>

    def append_objects_to_list_bucket_result(lbr, objects)
      return if objects.blank?

      # if objects.index(nil)
        # require 'ruby-debug'
        # Debugger.start
        # debugger
      # end

      objects.each do |s3_object|
        lbr.Contents do |contents|
          contents.Key(s3_object.key)
          contents.LastModified(s3_object.updated_at)
          contents.ETag("\"#{s3_object.md5}\"")
          contents.Size(s3_object.size)
          contents.StorageClass('STANDARD')

          contents.Owner do |owner|
            owner.ID('abc')
            owner.DisplayName('You')
          end
        end
      end
    end

    def bucket_query(bucket, query)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.ListBucketResult(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |lbr|
          selected_s3_objects = bucket.matches(query)
          lbr.Name(bucket.name)
          lbr.Prefix(query['prefix'])
          lbr.Marker(query['marker'])
          lbr.MaxKeys(query['max-keys'])
          lbr.IsTruncated(selected_s3_objects.count > query['max-keys'])
          append_objects_to_list_bucket_result(lbr, selected_s3_objects)
        end
      end
    end

    # ACL xml
    def acl(object = nil)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target:  output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.AccessControlPolicy(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |acp|
          acp.Owner do |owner|
            owner.ID('abc')
            owner.DisplayName('You')
          end
          acp.AccessControlList do |acl|
            acl.Grant do |grant|
              grant.Grantee('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                            'xsi:type' => 'CanonicalUser') do |grantee|
                grantee.ID('abc')
                grantee.DisplayName('You')
              end
              grant.Permission('FULL_CONTROL')
            end
          end
        end
      end
    end

    # <CopyObjectResult>
    #   <LastModified>2009-10-28T22:32:00</LastModified>
    #   <ETag>"9b2cf535f27731c974343645a3985328"</ETag>
    # </CopyObjectResult>
    def copy_object_result(object)
      ''.tap do |output|
        xml = Builder::XmlMarkup.new(target: output)
        xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
        xml.CopyObjectResult do |result|
          result.LastModified(object.modified_date)
          result.ETag("\"#{object.md5}\"")
        end
      end
    end
  end
end
