## Changelog

### 0.8.33
* When forcing parent synchronize remove self api notified link

### 0.8.32
* Fixed bug when forcing parent to be synchronized first, child gets synchronized at the same time

### 0.8.31
* Fixed bug when not synchronizing children without changes

### 0.8.30
* Fixed bug when using method ApiNotify.configuration.endpoint_active? and configuration not defined
* Add job to failed only when retries exhaused

### 0.8.29
* Added config_object to Configuration class. It allows to define config outside config.yml.

### 0.8.28
* Refactored existing method finding
* Limited response length in Log files

### 0.8.27
* Added possibility to separate notify_attributes for each endpoint

### 0.8.26
* Bug Fix - added :done to unique scope for ApiNotify::Task.

### 0.8.25
* Replaced idenficatiors with created_at in concataned string for hash generation

### 0.8.24
* Added sidekiq.logger.warn when sidekiq_retries_exhausted
* Added changes_hash field to tasks. It allows find unique unsumited tasks and prevent them for double executing.
* Added LOGGER to setup_task method to inform when task is being created
! By this changes you have to create new field for api_notify_tasks
    add_column :api_notify_tasks, :changes_hash, :string, limit: 32
    add_index :api_notify_tasks, :changes_hash

### 0.8.23
* Allow current request to execute parallel parent request, when using force_parent_sync. Downside is that it makes two requests when creating new child element with parent.

### 0.8.22
* Moved all_indentificators? and parent_api_notified_or_notify_it? to no_need_to_synchronize? method. And call unless mehod not delete.

### 0.8.21
* Added force_parent_sync attribute, to allow sync related model before current model even if it doesnt changed.
