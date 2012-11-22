bricks = %w(base git clean_assets frontend database heroku s3 active_admin active_admin_extras)
bricks.each do |brick_module|
  base_path = File.dirname(__FILE__)
  apply File.join(base_path, "active_admin_generator", "#{brick_module}.rb")
  brick_class = "active_admin_generator/#{brick_module}".camelize.constantize rescue nil
  if brick_class.present?
    brick = brick_class.new(base_path, self)
    if brick.apply?
      log "applying", "brick: #{brick.title}"
      brick.apply!
      log "applied", "brick: #{brick.title}"
    end
  end
end
