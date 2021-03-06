namespace :smartling do
  desc 'Update a translation file for a given locale'
  task :update_translation, %i[file locale] => [:environment] do |_, args|
    smartling = SmartlingAPI.new(
      user_id: ENV['SMARTLING_USER_ID'],
      user_secret: ENV['SMARTLING_USER_SECRET'],
      project_id: ENV['SMARTLING_PROJECT_ID']
    )

    puts 'Updating the file...'
    smartling.download_translated(filename: args[:file], locale: args[:locale])
    puts 'Done!'
  end

  desc 'Upload a file'
  task :upload_file, %i[file locale] => [:environment] do |_, args|
    # be rake "smartling:upload_file[_documentation/en/messages/overview.md,en]"
    smartling = SmartlingAPI.new(
      user_id: ENV['SMARTLING_USER_ID'],
      user_secret: ENV['SMARTLING_USER_SECRET'],
      project_id: ENV['SMARTLING_PROJECT_ID']
    )

    puts 'Uploading the file...'
    smartling.upload(args[:file])
    puts 'Done!'
  end

  desc 'Downloading a translation for a given locale'
  task :download_translation, %i[file locale type] => [:environment] do |_, args|
    # be rake "smartling:download_translation[_documentation/en/messages/overview.md,en-US,pseudo]"
    smartling = SmartlingAPI.new(
      user_id: ENV['SMARTLING_USER_ID'],
      user_secret: ENV['SMARTLING_USER_SECRET'],
      project_id: ENV['SMARTLING_PROJECT_ID']
    )

    puts 'Downloading the translation...'
    smartling.download_translated(filename: args[:file], locale: args[:locale], type: args[:type])
    puts 'Done!'
  end

  desc 'Check for new translations by locale and download them'
  task 'download': :environment do
    puts 'Checking for completed translations and downloading them'

    Translator::SmartlingDownloader.new.call

    puts 'Done!'
  end

  desc 'Create list of changed documentation files within a given number of days'
  task :check_docs_changes, %i[days] => [:environment] do |_, args|
    files = Translator::FilesListCoordinator.new(days: args[:days]).call

    puts files
  end

  desc 'Upload recently modified docs to Smartling for translation'
  task :upload, %i[paths frequency] => [:environment] do |_, args|
    # RAILS_ENV=production RAILS_LOG_TO_STDOUT=1 be nexmo-developer --docs=`pwd` --rake-smartling-upload  15 _documentation/en/messages/test.md _documentation/en/messages/external-accounts/overview.md
    puts "Uploading files to Smartling with a translation frequency of #{args[:frequency]} days..."
    puts args[:paths].join("\n")

    Translator::TranslatorCoordinator.new(
      paths: args[:paths],
      frequency: args[:frequency]
    ).create_smartling_jobs!

    puts 'Done!'
  end
end
