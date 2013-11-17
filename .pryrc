require 'call_me_maybe'

begin
  require 'awesome_print'
  Pry.config.print = proc { |output, value| output.puts value.ai }
rescue LoadError => err
  puts "no awesome_print :("
end

class New
  def apple
    puts "Apples are tasty ^_^"
  end

  def self.orange
    puts "Oranges are too sweet for me ^.^'"
  end

  call_me_maybe klass: "#{self}", method: :apple, event: :before do
    puts "Before Callback: Instance Level"
  end

  call_me_maybe klass: "#{self}", method: :orange, type: :class, event: :before do
    puts "Before Callback: Class Method"
  end

  call_me_maybe method: :apple, event: :after do
    puts "After Callback: Instance Level"
  end

  call_me_maybe klass: "New.orange", type: :class, event: :after do
    puts "After Callback: Class Method"
  end
end
