## Changelog

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
