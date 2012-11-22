module ActiveAdminGenerator
  module Base

    def title
      "Base"
    end

    def apply?
      true
    end

    def apply!
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
      say format(text)
    end

    def ask(question)
      ask format(question)
    end

    def choose(question, choices)
      title(question)
      values = {}
      choices.each_with_index do |choice,i|
        values[(i + 1).to_s] = choice[1]
        title("#{i.next.to_s}) #{choice[0]}")
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
