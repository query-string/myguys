module Api
  class UploadRequest
    def execute
      s3 = AWS::S3.new(
                       access_key_id: ENV["S3_KEY_ID"],
                       secret_access_key: ENV["S3_SECRET"]
                      )
      bucket = s3.buckets[ENV["S3_BUCKET_NAME"]]
      object = bucket.objects[filename]
      presign = AWS::S3::PresignV4.new(object)
      clean_uri(presign.presign(:put, expires: Time.now.to_i + 60*60, acl: "public-read"))
    end

    def clean_uri(uri)
      uri.port = 80
      uri
    end

    private

    def filename
      @filename ||= "#{SecureRandom.hex}.jpg"
    end
  end
end

