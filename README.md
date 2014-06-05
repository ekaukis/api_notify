[![Code Climate](https://codeclimate.com/github/ekaukis/api_notify.png)](https://codeclimate.com/github/ekaukis/api_notify)

# API notify

## Installation

    gem 'api_notify', :git => "https://github.com/ekaukis/api_notify.git"

    bundle

## Instruction

 * Add config file

        # config/initializers/api_notify.rb

        ApiNotify.configure do |config|
          config.active = false
          config.config_file = "#{Rails.root.to_s}/config/api_notify.yml"
        end

 * Add enpoints

        envoronment:
          one: #endpoint name
            domain: example.com
            port: 443
            base_path: /api/v1
            api_key: your_secret_api_key
          other: #endpoint name
            domain: example.com
            port: 443
            base_path: /api/v1
            api_key: your_secret_api_key

 * Add api_notify to models

        api_notify [
          :attribute_name,
          'association.attribute_name'
        ], # fields being checkd for changes
        {
          id: :id
        }, # Identificators
        {
          one: {
            skip_synchronize: :one_dont_do_synchronize,
          },
          other: {
            skip_synchronize: :other_dont_do_synchronize,
          }
        }, # endpoint config
        route_name: "the_route"


 * Define custom synchronization methods for each endpoint - skip_synchronize and is_synchronized

 * If nescessary add callbacks for succes or failing

   * api_notify_#{method}_success
   * api_notify_#{method}_failed

   ** methods are - post, delete, get and put

## API notify tables
Api notify gem uses Two tables, one for storing tasks and second for loging changes.
Both tables have polymorphic assosiation with api_notified models.
### api_notify_tasks
 * fields_updated - text (serialized hash)
 * api_notifiable - polymorphic fields combination ( points to api_notify model )
 * endpoint - string
 * done - boolean (true if synchronization succeded)
 * response - text (json or message from endpoint)

### api_notify_log
  Only one record for one api_notified instance

 * api_notify_logable - polymorphic fields combination ( points to api_notify model )
 * endpoint - on which endpoint it is synchronized


## Dependencies
 * Rails 4.0
 * Sidekiq
 * Redis

#### TODO
  * Make generators for configs and db migrations
