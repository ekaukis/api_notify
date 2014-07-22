## Changelog

### 0.8.23
* Allow current request to execute parallel parent request, when using force_parent_sync. Downside is that it makes two requests when creating new child element with parent.

### 0.8.22
* Moved all_indentificators? and parent_api_notified_or_notify_it? to no_need_to_synchronize? method. And call unless mehod not delete.

### 0.8.21
* Added force_parent_sync attribute, to allow sync related model before current model even if it doesnt changed.
