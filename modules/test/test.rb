class SSOModule < WebcoreApp()
    get "/" do
        puts "Test"
        "Hello World"
    end
end