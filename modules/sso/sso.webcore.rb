configure! do |m|
    m.id = :sso
    m.group = :webcore
    m.host = /auth\..*/
    m.module = "sso.rb"
end