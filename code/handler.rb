require 'json'
require 'inspec'
require 'aws-sdk'
require 'aws-ssm-env'

def generate_json_file(service_type)
  filename = 'inspec-' + service_type + '-' + Time.now.strftime("%Y-%m-%d_%H-%M-%S") + '.json'
  file_path = '/tmp/' + filename

  return filename, file_path
end

def inspec_scan(event:, context:)
    { event: JSON.generate(event), context: JSON.generate(context.inspect) }

    # Set filename
    filename,file_path = generate_json_file('aws')
    json_reporter = "json:" + file_path
    
    #Load SSH key
    if event.key?("SSH_KEY")
    client = Aws::SSM::Client.new(region: event['aws_region'])
    resp = client.get_parameters({
      names: [event['SSH_KEY']], # required
      with_decryption: true,
    })
    ssh_key = resp.parameters[0].value
    file_names = event['SSH_KEY']
    file_paths = '/tmp/' + file_names
    File.open(file_paths, "w") { |f| f.write "#{ssh_key}" }
    end
    # Set Runner Option
    opts = {
      "backend" => event['profile_type'],
      "reporter" => ["cli",json_reporter],
      "key_files" => file_paths,
      "host" =>  event['HOST'],
      "sudo" => "sudo",
      "user" => "ubuntu"
    }

    # Define InSpec Runner
    client = Inspec::Runner.new(opts)

    # Set InSpec Target
    profiles = event['inspec_profiles']
    if event.key?("inspec_profiles")
      profiles.each do |profile|
        client.add_target(profile,opts)
      end
    end

    # Trigger InSpec Scan
    client.run
    
    s3 = Aws::S3::Resource.new(region: event['aws_region'])
    bucket = event['s3_bucket'] or ENV['S3_DATA_BUCKET']
    # Create the object to upload
    obj = s3.bucket(bucket).object(filename)
    #return json_reporter
    #return file_path
    obj.upload_file(file_path)
    file_data = File.read file_path
    return file_data
    # Upload it      
    
end