namespace :tagmanager do
  desc "Removes attachments with a zero size"

  task rmnullattach: [:environment] do
    count_broken = 0
    Tagscan.with_attached_image.each do |p|
      next unless p.image.attached?

      puts "Found image attached to #{p.id}"
      next unless p.image.byte_size == 0

      puts "******Found broken image: #{p.id}"
      p.image.destroy
      count_broken += 1
    end
    puts "Found #{count_broken} broken images"
  end
end
