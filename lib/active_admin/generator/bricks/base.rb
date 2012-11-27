require 'active_support/core_ext'

module ::Bricks
  class Base

    attr_reader :context, :base_path

    delegate :inject_into_file, :directory, :copy_file, :remove_dir, :gsub_file,
             :rake, :generate, :route, :empty_directory, :gem, :git, :remove_file,
             :append_file, to: :context

    def initialize(context)
      @context = context
      @base_path = base_path
    end

    def title
      "Base"
    end

    def template(source)
      content = open(File.expand_path(context.find_in_source_paths(source.to_s))) {|input| input.binmode.read }
      context.copy_file source do
        ERB.new(content).result(binding)
      end
    end

    def apply?
      true
    end

    def commit_all(message)
      git add: "-A ."
      git commit: "-m '#{message}'"
    end

    def before_bundle
      say "=" * 80
      say "Welcome to ActiveAdmin Generator! :)".center(80) + "\n"
      say "=" * 80
    end

    def format(text)
      string = ""
      if title
        string << "\033[1m\033[36m"
        string << title.to_s.rjust(10)
        string << "\033[0m  "
      end
      string << text
      string
    end

    def say(text)
      @context.say format(text)
    end

    def ask(question)
      @context.ask format(question)
    end

    def choose(question, choices)
      say question
      values = {}
      choices.each_with_index do |choice,i|
        values[(i + 1).to_s] = choice[1]
        say "#{i.next.to_s}) #{choice[0]}"
      end
      answer = ask("Enter your selection:") while !values.keys.include?(answer)
      values[answer]
    end

    def yes?(question)
      answer = ask(question + " \033[33m(y/n)\033[0m")
      case answer.downcase
        when "yes", "y"
          true
        when "no", "n"
          false
        else
          yes?(question)
      end
    end

  end
end

