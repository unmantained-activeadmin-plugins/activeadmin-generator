base_path = File.dirname(template)
bricks = %w(base git cleanassets gitignore db heroku s3 activeadmin activeadmin_extras)

bricks.each do |brick_module|
  load_template File.join(base_path, "active_admin_generator", "#{brick_module}.rb")
  brick = "active_admin_generator/#{brick}".camelize.constantize.new
  if brick.apply?
    log "applying", "brick: #{brick}"
    brick.apply!
    log "applied", "brick: #{brick}"
  end
end
