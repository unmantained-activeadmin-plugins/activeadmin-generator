def run_bundle ; end

module Thor::Actions
  alias_method :old_source_paths, :source_paths
  def source_paths
    old_source_paths + [ File.expand_path(File.dirname(__FILE__)) ]
  end
end

bricks = %w(base git clean_assets frontend database heroku s3 active_admin active_admin_extras)
bricks.each do |brick_module|
  apply File.join("active_admin_generator", "#{brick_module}.rb")
  brick_class = "active_admin_generator/#{brick_module}".camelize.constantize rescue nil
  if brick_class.present?
    brick = brick_class.new(self)
    if brick.apply?
      log "applying", "brick: #{brick.title}"
      brick.apply!
      log "applied", "brick: #{brick.title}"
    end
  end
end
