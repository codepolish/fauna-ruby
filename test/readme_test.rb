require File.expand_path('../test_helper', __FILE__)

class ReadmeTest < MiniTest::Unit::TestCase
  def test_readme
    code = ""

    sections = File.read(File.expand_path("../../README.md", __FILE__)).split("```")
    sections.select do |text|
      if text =~ /^ruby/
        next if text =~ /ActionController|logger/
        text.gsub!('$fauna = Fauna::Connection.new(secret: server_key)', '$fauna = SERVER_CONNECTION')
        code << text[4..-1]
      end
    end

    tmp = File.open("/tmp/fauna-ruby-readme-eval.rb", "w")
    tmp.write(code)
    tmp.close

    begin
      load tmp.path
    rescue => e
      puts e.inspect
      puts e.backtrace
      raise
    end

    File.delete(tmp.path)
  end
end
