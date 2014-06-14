require 'csv'
require 'aws-sdk'

class DbDump
  @host = Rails.configuration.database_configuration[Rails.env]["host"]
  @username = Rails.configuration.database_configuration[Rails.env]["username"]
  @password = Rails.configuration.database_configuration[Rails.env]["password"]
  @database = Rails.configuration.database_configuration[Rails.env]["database"]

  def self.get_client
    Mysql2::Client.new(host: @host,
                       username: @username,
                       password: @password,
                       database: @database)
  end

  def self.dump_hives
    file = 'dbdumps/hives.csv'
    client = get_client
    results = client.query("SELECT * FROM
                              ((SELECT id,
                                       name,
                                       breed,
                                       hive_type,
                                       null AS 'latitude',
                                       null AS 'longitude',
                                       city,
                                       state
                                   FROM hives
                                   WHERE donation_enabled = 1 AND
                                         fine_location_sharing = 0)
                           UNION
                               (SELECT id,
                                       name,
                                       breed,
                                       hive_type,
                                       latitude,
                                       longitude,
                                       city,
                                       state
                                   FROM hives
                                   WHERE donation_enabled = 1 AND
                                         fine_location_sharing = 1))
      AS hives")
    write_file(results, file)
    upload_dump(file)
  end

  def self.dump_inspections
    file = 'dbdumps/inspections.csv'
    client = get_client
    results = client.query("SELECT inspections.id,
                                   hive_id,
                                   weather_conditions,
                                   weather_notes,
                                   notes, inspections.ventilated,
                                   inspections.entrance_reducer,
                                   inspections.queen_excluder,
                                   inspections.hive_orientation,
                                   inspections.flight_pattern,
                                   health,
                                   inspected_at
                              FROM inspections, hives
                              WHERE inspections.hive_id = hives.id AND
                                    hives.donation_enabled = 1")
    inspections = []
    results.each do | inspection |
      inspections.push(inspection['id'])
    end

    #write_file(results, file)
    #upload_dump(file)

    dump_diseases(inspections)
    dump_honey_supers(inspections)
    dump_brood_boxes(inspections)
  end

  def self.dump_diseases(inspection_ids)
    file = 'dbdumps/diseases.csv'
    diseases = Disease.select(:id, :inspection_id, :disease_type, :treatment)
                      .where('inspection_id IN (?)', inspection_ids)
    write_file(diseases.to_a.map(&:serializable_hash), file)
    upload_dump(file)
  end

  def self.dump_honey_supers(inspection_ids)
    file = 'dbdumps/honey_supers.csv'
    supers = HoneySuper.select(:id, :inspection_id, :full, :capped, :ready_for_harvest)
                      .where('inspection_id IN (?)', inspection_ids)
    write_file(supers.to_a.map(&:serializable_hash), file)
    upload_dump(file)
  end

  def self.dump_brood_boxes(inspection_ids)
    file = 'dbdumps/brood_boxes.csv'
    boxes = BroodBox.select(:id,
                            :inspection_id,
                            :pattern,
                            :eggs_sighted,
                            :queen_sighted,
                            :queen_cells_sighted,
                            :swarm_cells_capped,
                            :honey_sighted,
                            :pollen_sighted,
                            :swarm_cell_sighted,
                            :supercedure_cell_sighted)
                      .where('inspection_id IN (?)', inspection_ids)
    write_file(boxes.to_a.map(&:serializable_hash), file)
    upload_dump(file)
  end

  def self.dump_harvests
    file = 'dbdumps/harvests.csv'
    client = get_client
    results = client.query("SELECT harvests.id,
                                   hive_id,
                                   honey_weight,
                                   wax_weight,
                                   weight_units,
                                   notes,
                                   harvested_at
	                            FROM harvests, hives
                              WHERE harvests.hive_id = hives.id AND
		                                hives.donation_enabled = 1;")

    write_file(results, file)
    upload_dump(file)
  end

private
  def self.upload_dump(filename)
    AWS.config(
      :access_key_id => Rails.application.secrets.aws_access_key_id,
      :secret_access_key => Rails.application.secrets.aws_secret_access_key
    )

    bucket_name = Rails.application.secrets.s3_bucket

    # Get an instance of the S3 interface.
    s3 = AWS::S3.new
    file = File.open(filename, 'r+')
    # Upload a file.
    key = "dumps/#{File.basename(filename)}"
    s3.buckets[bucket_name].objects[key].write(file: filename)
  end

  def self.write_file(results, filename)
    if results.count == 0
      File.open(filename, 'w')
    else
      keys = results.first.keys
      CSV.open(filename, 'w') do |csv|
        csv << keys
        results.each do |obj|
          csv << obj.values
        end
      end
    end
  end
end
