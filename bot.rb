require "telegram/bot"
require "mimemagic"
require "dotenv/load"
require "yaml"
require "colorize"

Dotenv.load

TOKEN   = ENV["TOKEN"]
CHANNEL = ENV["CHANNEL"]

channels = YAML.load File.read 'channels.yml'


class Telegram::Bot::Client
  def fire(channel)
    folder = channel["folder"]
    files = Dir.entries(folder).filter { |f| f != "." && f != ".." }
    if files.size == 0
      puts "Image folder is empty :C".red
      return
    end
    file = files.sample
    file_path = "#{folder}/#{file}"
    ext = MimeMagic.by_magic(File.open(file_path)).type

    puts "There are #{files.size} files"
    puts "My choice is...  #{file}! (#{ext})"
    puts "Fire!".yellow

    self.api.send_photo(chat_id: channel["id"], photo: Faraday::UploadIO.new(file_path, ext))

    File.delete(file_path)

    puts "Done!".green
    puts
  end
end


$bot = Telegram::Bot::Client.new(TOKEN) 

channels.each do |title, channel|
  $bot.fire channel
end