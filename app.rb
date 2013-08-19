require "sinatra/base"
require "sinatra/config_file"
require "sass"
require "haml"
require "json"

module Lilyedit
  class App < Sinatra::Base
    LyPath = "public/ly"
    OutputPath = "public/output"
    ConfigPath = "./config.yml"

    configure do
      register Sinatra::ConfigFile
      config_file ConfigPath
      config = settings.config
      @@lilypond_path = config.fetch("lilypond_path", "lilypond")
      @@lilypond_version = config.fetch("lilypond_version", "2.14.2")
    end

    get '/' do
      @lilypond_version = @@lilypond_version
      haml :index
    end
    get '/le/:fileid' do
      @fileid = params[:fileid]
      @code = ""
      begin
        File.open(File.join(LyPath, @fileid + ".ly"), "r") do |file|
          @code = file.read
        end
      rescue
      end
      haml :le
    end
    def write_file(fileid)
      request.body.rewind
      s = request.body.read
      filename = File.join(LyPath, fileid + ".ly")
      begin
        File.open(filename, "w") do |file|
          file.write(s)
        end
      rescue => exc
        return false, exc.to_s
      end
      return true, ""
    end
    post '/create' do
      fileid = Time.now.to_i.to_s
      ok, message = write_file(fileid)
      r = {"result" => (ok ? "true" : "false"),
           "url" => (ok ? "/le/#{fileid}" : ""),
           "message" => message}
      JSON.generate(r)
    end
    post '/save/:fileid' do
      ok, message = write_file(params[:fileid])
      r = {"result" => (ok ? "true" : "false"),
           "message" => message}
      JSON.generate(r)
    end
    post '/compile/:fileid' do
      fileid = params[:fileid]
      ok, response = write_file(fileid)
      if ok then
        filename = File.join(LyPath, fileid + ".ly")
        output = File.join(OutputPath, fileid)
        pipe_r, pipe_w = IO.pipe
        pid = spawn(@@lilypond_path, "-o", output, filename, [:err, :out] => pipe_w)
        pipe_w.close
        pid, stat = Process.waitpid2(pid)
        response = pipe_r.read
        ok = (stat.exitstatus == 0)
      end
      r = {"result" => (ok ? "true" : "false"),
           "url" => (ok ? "/output/#{fileid}.pdf" : ""),
           "response" => response}
      JSON.generate(r)
    end

    get '/css/base.css' do
      scss :base
    end
  end
end
