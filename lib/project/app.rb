require 'open-uri'
require 'active_support/core_ext'

module Project
  class App < Sinatra::Base
    set :root, Project.root
    enable :sessions

    set :sprockets, Sprockets::Environment.new(root) { |env|
      env.append_path(root.join('app', 'assets', 'stylesheets'))
      env.append_path(root.join('app', 'assets', 'javascripts'))
      env.append_path(root.join('app', 'assets', 'images'))
    }

    configure :development do
      register Sinatra::Reloader
    end

    helpers do
      def asset_path(source)
        if Project.env == "production"
          "/assets/" + settings.sprockets.find_asset(source).digest_path
        else
          "/assets/" + settings.sprockets.find_asset(source).logical_path
        end
      end
    end

    get '/' do
      erb :index
    end

    post '/search' do
      @results = []
      @q = params[:q]

      time_ranges.each do |k, v|
        url = "https://www.google.com/search?q=#{@q}&as_qdr=" + k
        page = Nokogiri::HTML(open(url))
        result = page.css("#resultStats").first.content

        if scan = result[/About (.+) results/, 1]
          num_results     = scan.gsub(",", "").to_f
          results_per_day = (num_results / v.fetch("days").to_f).round
        else
          results_per_day = 0
        end

        @results << { "date" => v.fetch("date"), "result" => results_per_day }
      end

      erb :search
    end

    def time_ranges
      {
        "d" => { "date" => Date.today, "days" => 1 },
        "w" => { "date" => 1.weeks.ago.to_date, "days" => 7 },
        "m" => { "date" => 1.month.ago.to_date, "days" => 30 },
        "m6" => { "date" => 6.months.ago.to_date, "days" => 182 },
        "y" => { "date" => 1.year.ago.to_date, "days" => 165 },
        "y2" => { "date" => 2.years.ago.to_date, "days" => 730 },
      }
    end
  end
end