module AresMUSH
  module Website
    class StartDivBlockMarkdownExtension
      def self.regex
        /(<p>)?(<br>)?\[\[div([^\]]*)\]\](<\/?br\/?>)?(<\/p>)?/i
      end
      
      def self.parse(matches)
        input = matches[3]
        "<div #{input}>"
      end
    end
    
    class EndDivBlockMarkdownExtension
      def self.regex
        /(<p>)?(<br>)?\[\[\/div\]\](<\/?br\/?>)?(<\/p>)?/i
      end
      
      def self.parse(matches)
        "</div>"
      end
    end
  end
end