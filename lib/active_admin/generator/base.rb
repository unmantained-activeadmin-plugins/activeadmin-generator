class Base
  BRICKS = %w(init git clean_assets errbit frontend database heroku active_admin active_admin_extras)
  attr_reader :context

  def initialize(context)
    @context = context
  end

  def require_bricks
    context.apply "bricks/base.rb"
    BRICKS.each do |brick_module|
      context.apply "bricks/#{brick_module}.rb"
    end
  end

  def bricks
    @bricks ||= BRICKS.map do |brick_module|
      brick_class = "bricks/#{brick_module}".camelize.constantize
      brick = brick_class.new(context)
      brick.apply? ? brick : nil
    end.compact
  end

  def run!
    require_bricks

    hook :before_bundle
      context.run "bundle install"
    hook :after_bundle

    hook :before_migrate
      context.rake "db:migrate"
    hook :after_migrate

    hook :recap
  end

  def hook(name)
    bricks.each do |brick|
      puts brick.class.name
      if brick.respond_to? name
        brick.send(name)
      end
    end
  end
end


module Thor::Actions
  alias_method :old_source_paths, :source_paths
  def source_paths
    [ File.expand_path(File.dirname(__FILE__)), File.join(File.expand_path(File.dirname(__FILE__)), "templates") ] + old_source_paths
  end
end

def run_bundle; end

Base.new(self).run!

