configure! do |m|
    m.id = :management
    m.host = /manage\..*/
    m.module = "management.rb"
end