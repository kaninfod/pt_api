namespace :phototank do

  desc "Initialize the app"
  task Initialize: :environment do

    ['tm', 'md', 'lg'].each do |ext|
      path = File.join(Rails.root,'config','setup', "generic_#{ext}.jpg")
      payload = {
        :path=> path,
        :filetype=> "system",
      }
      response = Photofile.create(data:payload)
      Setting["generic_image_#{ext}_id"] = response[:id]
    end

    # sql = """
    #   DROP FUNCTION IF EXISTS `HAMMINGDISTANCE`;
    #   CREATE DEFINER=`root`@`localhost` FUNCTION `HAMMINGDISTANCE`(A BINARY(32), B BINARY(32)) RETURNS int(11)
    #       DETERMINISTIC
    #   RETURN
    #     BIT_COUNT(CONV(HEX(SUBSTRING(A, 1,  8)), 16, 10) ^CONV(HEX(SUBSTRING(B, 1,  8)), 16, 10))
    #     +BIT_COUNT(  CONV(HEX(SUBSTRING(A, 9,  8)), 16, 10) ^  CONV(HEX(SUBSTRING(B, 9,  8)), 16, 10))
    #     +BIT_COUNT(  CONV(HEX(SUBSTRING(A, 17, 8)), 16, 10) ^  CONV(HEX(SUBSTRING(B, 17, 8)), 16, 10))
    #     +BIT_COUNT(  CONV(HEX(SUBSTRING(A, 25, 8)), 16, 10) ^  CONV(HEX(SUBSTRING(B, 25, 8)), 16, 10));
    # """
    #
    # ActiveRecord::Base.connection.execute(sql)

  end


  desc "Create admin user"
  task create_admin: :environment do
    admin = User.create!(email: 'admin@mail.com' , password: '123' , password_confirmation: '123')
    MasterCatalog.create(default: true, user: admin, name: "Master")
  end

  desc "Set the updating flag to false to allow updates"
  task master_not_updating: :environment do
    Catalog.master.settings.updating = false
  end

  desc 'Stop rails server'
  task :stop do
    File.new("tmp/pids/server.pid").tap { |f| Process.kill 9, f.read.to_i }.delete
  end

  desc 'Starts rails server'
  task :start do
    Process.exec("rails s puma -d")
  end

  desc "Restarts rails server"
  task :restart do
    Rake::Task[:stop].invoke
    Rake::Task[:start].invoke
  end

end
