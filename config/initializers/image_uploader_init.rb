if !Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :s3
    config.s3_access_key_id = 'AKIAIV6BPALXKX5RIUEA'       # required
    config.s3_secret_access_key = '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'  
    config.s3_bucket = 'spottymouth'
    config.s3_region = 'us-east-1'  
  end
  else
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end
