#!/usr/bin/env ruby

require "bundler/setup"
require "json"
require "sinatra"
require "./helpers"

if development?
  require "sinatra/reloader"
  require "pry-byebug"
end

WHATUP_JSON_FILE = "./data/helm-whatup.json"
TF_MODULES_JSON_FILE = "./data/module-versions.json"

def require_api_key(request)
  if correct_api_key?(request)
    yield
    status 200
  else
    status 403
  end
end

get "/" do
  redirect "/helm_whatup"
end

get "/helm_whatup" do
  data = JSON.parse(File.read WHATUP_JSON_FILE)
  apps = data.fetch("apps")
  updated_at = data.fetch("updated_at")
  apps.map { |app| app["trafficLight"] = version_lag_traffic_light(app) }
  erb :helm_whatup, locals: {
    active_nav: "helm_whatup",
    apps: apps,
    updated_at: updated_at
  }
end

post "/helm_whatup" do
  require_api_key(request) do
    payload = request.body.read
    data = {
      "apps" => JSON.parse(payload),
      "updated_at" => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    File.open(WHATUP_JSON_FILE, "w") {|f| f.puts(data.to_json)}
  end
end

get "/terraform_modules" do
  modules = []
  updated_at = ""

  if FileTest.exists?(TF_MODULES_JSON_FILE)
    data = JSON.parse(File.read TF_MODULES_JSON_FILE)
    updated_at = data.fetch("updated_at")
    modules = data.fetch("out_of_date_modules")
  end

  erb :terraform_modules, locals: {
    active_nav: "terraform_modules",
    modules: modules,
    updated_at: updated_at
  }
end

post "/terraform_modules" do
  require_api_key(request) do
    File.open(TF_MODULES_JSON_FILE, "w") {|f| f.puts(request.body.read)}
  end
end
