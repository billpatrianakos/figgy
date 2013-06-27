require "yaml"
require "erb"
require "json"

require "figgy/version"
require "figgy/configuration"
require "figgy/hash"
require "figgy/finder"
require "figgy/store"

# An instance of Figgy is the object used to provide access to your
# configuration files. This does very little but recognize missing
# methods and go look them up as a configuration key.
#
# To create a new instance, you probably want to use +Figgy.build+:
#
#   MyConfig = Figgy.build do |config|
#     config.root = '/path/to/my/configs'
#   end
#   MyConfig.foo.bar #=> read from /path/to/my/configs/foo.yml
#
# This should maybe be a BasicObject or similar, to provide as many
# available configuration keys as possible. Maybe.
class Figgy
  FileNotFound = Class.new(StandardError)

  # @yield [Figgy::Configuration] an object to set things up with
  # @return [Figgy] a Figgy instance using the configuration
  def self.build(&block)
    config = Configuration.new
    block.call(config)
    new(config)
  end

  attr_reader :pivots

  def initialize(config)
    @config = config
    @finder = Finder.new(config)
    @store  = Store.new(@finder, config)
    if config.preload?
      @finder.all_key_names.each { |key| @store.get(key) }
    end
    if config.pivot
      # create method named +pivot+
      self.class.class_eval <<-EOF, __FILE__, __LINE__
         def #{config.pivot}(pivot_point)
           pivots[pivot_point]
         end
      EOF
      orig_roots = config.roots
      # create hash of additional finders/stores for each +pivot_prefix found
      @pivots = Hash.new
      @pivots.default= @store
      Dir[File.join(config.roots.first,"#{config.pivot_prefix}_*")].each do |pivot_root|
        pivot_name = pivot_root.gsub(/.*#{config.pivot_prefix}_/,'')
        pivot_config = config.clone
        pivot_config.roots = orig_roots.clone
        pivot_config.prefix_root(pivot_root)
        pivot_finder = Finder.new(pivot_config)
        pivot_store  = Store.new(pivot_finder, pivot_config)
        if config.preload?
          pivot_finder.all_key_names.each { |key| pivot_store.get(key) }
        end
        @pivots[pivot_name] = pivot_store
      end
    end
  end

  # RSpec calls to_ary on a should check
  # quick and dirty hack until I figure out what should be done
  def to_ary
    nil
  end

  def method_missing(m, *args, &block)
    @store.get(m)
  end

  def inspect
    if @store.size > 0
      key_names = @store.keys.sort
      "#<Figgy (#{@store.size} keys): #{key_names.join(' ')}>"
    else
      "#<Figgy (empty)>"
    end
  end
end
