configure! do |m|
    m.id = :admin
    m.group = :webcore
    m.host = /admin\..*/
    m.priority = 75
    m.module = "admin.rb"
end