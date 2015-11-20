###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

Slim::Engine.disable_option_validator!
Slim::Engine.set_options pretty: true
Slim::Engine.set_options attr_list_delims: { '(' => ')', '[' => ']' }

# set default layout
set :layout, 'ukti'

###
# Helpers
###

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload, ignore: [/source\/images\//]
end

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Load sass paths
%w(mojular-govuk-elements).map do |i|
  meta = JSON.parse(IO.read("node_modules/#{i}/package.json"))
  begin
    meta['sassPaths'].each do |path|
      Sass.load_paths << (File.directory?(path) ? path : File.expand_path("node_modules/#{meta['name']}/#{p}"))
    end
  rescue
    p 'ERROR: Sass paths not found'
  end
  # Copy images
  `mkdir -p source/images && cp node_modules/#{i}/images/* source/images`
end
# Copy layouts
`mkdir -p source/layouts && cp #{root}/node_modules/mojular-templates/layouts/erb/* source/layouts`

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

# Build-specific configuration
configure :build do
  set :relative_links, true

  # Use relative URLs
  activate :relative_assets

  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end
