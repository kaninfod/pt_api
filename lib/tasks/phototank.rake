namespace :phototank do
  desc "Initialize the app"
  task initialize: :environment do

    Setting.master_catalog = MasterCatalog.create_master

    ['tm', 'md', 'lg'].each do |ext|
      path = File.join(Rails.root,'config','setup', "generic_#{ext}.jpg")
      payload = {
        :path=> path,
        :filetype=> "system",
      }
      response = Photofile.create(data:payload)
      Setting["generic_image_#{ext}_id"] = response[:id]
    end

    User.create!(email: 'admin@mail.com' , password: '123' , password_confirmation: '123')

    sql = """
      DROP FUNCTION IF EXISTS `HAMMINGDISTANCE`;
      CREATE DEFINER=`root`@`localhost` FUNCTION `HAMMINGDISTANCE`(A BINARY(32), B BINARY(32)) RETURNS int(11)
          DETERMINISTIC
      RETURN
        BIT_COUNT(CONV(HEX(SUBSTRING(A, 1,  8)), 16, 10) ^CONV(HEX(SUBSTRING(B, 1,  8)), 16, 10))
        +BIT_COUNT(  CONV(HEX(SUBSTRING(A, 9,  8)), 16, 10) ^  CONV(HEX(SUBSTRING(B, 9,  8)), 16, 10))
        +BIT_COUNT(  CONV(HEX(SUBSTRING(A, 17, 8)), 16, 10) ^  CONV(HEX(SUBSTRING(B, 17, 8)), 16, 10))
        +BIT_COUNT(  CONV(HEX(SUBSTRING(A, 25, 8)), 16, 10) ^  CONV(HEX(SUBSTRING(B, 25, 8)), 16, 10));
    """

    ActiveRecord::Base.connection.execute(sql)

  end


  desc "Create the Master catalog"
  task create_master_catalog: :environment do
    MasterCatalog.create_master
  end

  desc "add generic photos (eg missing)"
  task Add_generic_photo: :environment do

    ['tm', 'md', 'lg'].each do |ext|
      image_path = File.join(Rails.root,'config', 'setup', "generic_#{ext}.jpg")
      response = Photofile.create(data: {:path => image_path, :filetype => 'generic_image', :size => ext})
      Setting["generic_image_#{ext}_id"] = response[:id]
    end

  end
  desc "Set the updating flag to false to allow updates"
  task master_not_updating: :environment do
    Catalog.master.settings.updating = false
  end
end
