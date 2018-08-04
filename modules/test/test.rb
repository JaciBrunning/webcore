class SSOModule < WebcoreApp()
    get "/" do
        puts "Test"
        "Hello World"
    end

    not_found do
        "Not found here!"
    end
end