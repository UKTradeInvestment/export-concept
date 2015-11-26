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

data.countries.each do |country|
  file_url = country.name.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
  proxy "/markets/#{file_url}.html", "/market.html", :locals => { :country => country }, :ignore => true
end

ignore "/market.html"

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

  def str_to_url(str)
    str.downcase.gsub(' ', '-').gsub(/[^a-z0-9-]/,'')
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
