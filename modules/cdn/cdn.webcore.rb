configure! do |m|
    m.id = :cdn
    m.group = :webcore
    m.host = /cdn\..*/
    m.module = "cdn.rb"
end