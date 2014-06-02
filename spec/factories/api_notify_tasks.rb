# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_notify_task, :class => 'ApiNotifyTasks' do
    fields_updated "MyText"
    notifiable nil
    synchronized_to "MyText"
    synchronized false
  end
end
