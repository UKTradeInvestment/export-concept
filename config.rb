require 'cgi'

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/partials/*', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

ready do
  app.data.countries.each do |country|
    country[:stub] = country.name.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
    country[:url] = "/markets/#{country[:stub]}/index.html"
    country[:data] = country[:data] || {
      gdp: "39,189",
      population: "63m",
      exchange_rate: 0.67,
      currency: "Euro",
      inflation: 3,
      growth: 0.6,
      deficit: -4.6,
      imports: "639b",
      imports_uk: "700m",
      unemployment: 5,
    }

    app.data.industries.each do |k,industry|
      industry[:stub] = industry.name.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
      industry[:url] = "markets/#{country[:stub]}/#{industry[:stub]}.html"
      proxy industry[:url], "/industry.html", :locals => { :industry => industry, :country => country }, :ignore => true
    end

    proxy "markets/#{country[:stub]}/industries.html", "/industries.html", :locals => { :country => country }, :ignore => true
    proxy country[:url], "/market.html", :locals => { :country => country }, :ignore => true
  end

  # opportunities
  data.opportunities.each do |opportunity|
    file_url = opportunity.title.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
    proxy "/opportunities/#{file_url}.html", "/document.html", :locals => { :document => opportunity, :parent => "Contracts, tenders and projects", :parent_url => "opportunities", type: "opportunity" }, :ignore => true
  end

  # events
  data.events.each do |event|
    file_url = event.title.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
    proxy "/events/#{file_url}.html", "/document.html", :locals => { :document => event, :parent => "Events, workshops and visits", :parent_url => "events", type: "event" }, :ignore => true
  end

  # proxy data to json files
  ["countries", "industries", "regions", "opportunities", "events"].each do |source|
    proxy "/data/#{source}.json", "/data.json", :locals => { :source => source }, :ignore => true
  end
end

# ignore proxy templates
ignore "/market.html"
ignore "/industry.html"
ignore "/industries.html"
ignore "/document.html"
ignore "/data.json"

Slim::Engine.disable_option_validator!
Slim::Engine.set_options pretty: true
Slim::Engine.set_options attr_list_delims: { '(' => ')', '[' => ']' }

# set default layout
set :layout, 'ukti'

###
# Helpers
###

## Methods defined in the helpers block are available in templates
helpers do
  def get_countries_by_letter()
    countries = data.countries.map do |c|
      c.name
    end

    countries.sort.group_by {|word| word[0].upcase }
  end

  def sort_countries()
    countries = data.countries.map do |c|
      c.name
    end

    countries.sort
  end

  def get_industries_by_letter()
    industries = data.industries.map do |k,v|
      v.name
    end

    industries.sort.group_by {|word| word[0].upcase }
  end

  def sort_industries()
    industries = data.industries.map do |k,v|
      v.name
    end

    industries.sort
  end

  def str_to_url(str)
    str.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
  end

  def url_encode(str)
    CGI.escape(str).gsub('+', '%20')
  end

  def markdown(content)
    Tilt['markdown'].new { content }.render(scope=self)
  end

  def date_format(dateStr)
    Date.parse(dateStr.to_s).strftime('%-d %B %Y')
  end

  def opportunities_by_country(country)
    data.opportunities.select { |e| e.meta.market == country }
  end

  def events_by_country(country)
    data.events.select { |e| e.meta.market == country }
  end

  def opportunities_by_country_and_industry(country, industry)
    data.opportunities.select { |e| e.meta.market == country && e.meta.sector == industry }
  end

  def events_by_country_and_industry(country, industry)
    data.events.select { |e| e.meta.market == country && e.meta.sector == industry }
  end

  def copy(key)
    if key
      markdown key
    else
      markdown lorem.paragraphs 2
    end
  end
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Load Sass paths and copy images & layouts
require 'find'
`mkdir -p "#{config.source}/#{config.images_dir}" "#{config.source}/#{config.layouts_dir}"`
Find.find('node_modules').grep(/mojular[a-z-]+\/package\.json/).map do |package|
  sassPaths = JSON.parse(IO.read(package))['sassPaths']
  dirname = File.dirname(package)
  sassPaths.map { |path| Sass.load_paths << File.expand_path(path, File.directory?(path) ? '' : dirname) } if sassPaths
  FileUtils.cp_r Find.find(dirname).grep(/images\//), "#{config.source}/#{config.images_dir}"
  FileUtils.cp_r Find.find(dirname).grep(/layouts\/erb\//), "#{config.source}/#{config.layouts_dir}"
end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
