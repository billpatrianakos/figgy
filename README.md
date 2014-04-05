# figgy

Provides convenient access to configuration files in various formats, with
support for overriding the values based on environment, hostname, locale, or
any other arbitrary thing you happen to come up with.

## Travis-CI Build Status
[![Build Status](https://secure.travis-ci.org/kingmt/figgy.png)](http://travis-ci.org/kingmt/figgy)

## Documentation
[yardocs](http://rdoc.info/github/pd/figgy/master/frames)

## Installation

Just like everything else these days. In your Gemfile:

    gem 'figgy'

## Overview

Set it up (say, in a Rails initializer):

    AppConfig = Figgy.build do |config|
      config.root = Rails.root.join('etc')

      # config.foo is read from etc/foo.yml
      config.define_overlay :default, nil

      # config.foo is then updated with values from etc/production/foo.yml
      config.define_overlay(:environment) { Rails.env }

      # Maybe you need to load XML files?
      config.define_handler 'xml' do |contents|
        Hash.from_xml(contents)
      end
    end

Access it as a dottable, indifferent-access hash:

    AppConfig.foo.some_key
    AppConfig["foo"]["some_key"]
    AppConfig[:foo].some_key

Multiple overlays can be defined to cascade
    AppConfig = Figgy.build do |config|
      config.root = Rails.root.join('etc')
      config.define_overlay :default, nil

      # config.foo is then updated with values from etc/development/foo.yml
      #                                        then etc/staging/foo.yml
      #                                        then etc/production/foo.yml
      # up to the current Rails environment
      config.define_overlay(:environment), ['development', 'staging', 'production'].slice(0..(env.index(Rails.env)))
    end

Multiple overlays can be defined to be combined
    AppConfig = Figgy.build do |config|
      config.root = Rails.root.join('etc')
      config.define_overlay :default, nil

      # config.foo is then updated with values from etc/development/foo.yml
      #                                        then etc/staging/foo.yml
      #                                        then etc/production/foo.yml
      #                                        from etc/US/foo.yml
      #                                        from etc/development_US/foo.yml
      #                                        then etc/staging_US/foo.yml
      #                                        then etc/production_US/foo.yml
      # up to the current Rails environment
      config.define_overlay(:environment), ['development', 'staging', 'production'].slice(0..(env.index(Rails.env)))
      config.define_overlay :country, 'US'
      config.define_combined_overlay :environment, :country
    end

Multiple cascading overlays can be defined to be combined
    AppConfig = Figgy.build do |config|
      config.root = Rails.root.join('etc')
      config.define_overlay :default, nil

      # config.foo is then updated with values from etc/development/foo.yml
      #                                        then etc/staging/foo.yml
      #                                        then etc/production/foo.yml
      #                                        from etc/a1/foo.yml
      #                                        from etc/b2/foo.yml
      #                                        from etc/c3/foo.yml
      #                                        from etc/development_a1/foo.yml
      #                                        from etc/development_b2/foo.yml
      #                                        from etc/development_c3/foo.yml
      #                                        then etc/staging_a1/foo.yml
      #                                        then etc/staging_b2/foo.yml
      #                                        then etc/staging_c3/foo.yml
      #                                        then etc/production_a1/foo.yml
      #                                        then etc/production_b2/foo.yml
      #                                        then etc/production_c3/foo.yml
      # up to the current Rails environment
      config.define_overlay(:environment), %w(development staging production).slice(0..(env.index(Rails.env)))
      config.define_overlay :arbitrary, %w(a1 b2 c3)
      config.define_combined_overlay :environment, :arbitrary
    end

Multiple root directories may be specified, so that configuration files live in
more than one place (say, in gems):

    AppConfig = Figgy.build do |config|
      config.root = Rails.root.join('etc')
      config.add_root Rails.root.join('vendor/etc')
    end

Precedence of root directories is in reverse order of definition, such that the
root directory added first (typically the one immediately within the application)
has highest precedence. In this way, defaults can be inherited from libraries,
but then overridden when necessary within the application.

Pivot overlays can be defined to provide alternate datasets, an I18n example:
    AppConfig = Figgy.build do |config|
      config.root = Rails.root.join('etc')
      config.define_overlay :default, nil
      config.define_overlay :environment, :development
      config.define_pivot_overlay :language, :lang
    end

    Assuming the following directory structure:
      etc
       |- foo.yml
       |- development
       |   |- foo.yml
       |- lang_en
       |   |- foo.yml
       |   |- development
       |       |- foo.yml
       |- lang.es
       |   |- foo.yml
       |   |- development
       |       |- foo.yml

    AppConfig.foo.value is defined in etc/foo.yml + etc/development/foo.yml
    AppConfig.language('en').foo.value is defined by etc/foo.yml + etc/development/foo.yml + etc/lang_en/foo.yml + etc/lang_en/development/foo.yml
    AppConfig.language('es').foo.value is defined by etc/foo.yml + etc/development/foo.yml + etc/lang_es/foo.yml + etc/lang_es/development/foo.yml
    AppConfig.language('de').foo.value is defined by etc/foo.yml + etc/development/foo.yml
=======


## Caveats

Because the objects exposed by figgy are often hashes, all of the instance methods
of Hash (and, of course, Enumerable) are available along the chain. But note that
this means you can not use key names such as `size` or `each` with the dottable
access style:

    AppConfig.price.bulk   #=> 100.00
    AppConfig.price.each   #=> attempts to invoke Hash#each
    AppConfig.price[:each] #=> 50.00

## Thanks

This was written by pd on [Enova Financial's](http://www.enovafinancial.com) dime/time.
Extensions written by kingmt
