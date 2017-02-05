# Generate pages for category entries in a data file (yml or json) in the _data folder
# (c) 2017 Affan Sajid
# Distributed under the conditions of the MIT License

module Jekyll

  module Slugify
    # strip characters and whitespace to create valid page_file_names, also lowercase
    def slugify_name(name)
      if(name.is_a? Integer)
        return name.to_s
      end
      
      parameterized_string = name.downcase
      sep = '-'
      # Turn unwanted chars into the separator
      parameterized_string.gsub!(/[^a-z0-9\-_]+/, sep)
      unless sep.nil? || sep.empty?
        re_sep = Regexp.escape(sep)
        # No more than one of the separator in a row.
        parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
        # Remove leading/trailing separator.
        parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
      end
      parameterized_string

    end
  end



  class CategoryPage < Page
    include Slugify

    # 'directory' is the output directory for our category page file
    # 'category' is the data entry of the category in the json|yml data_file for which we are generating a page
    # 'category_key' is the key in 'data' which determines the output page_file_name
    # 'template' is the name of the template used to generate the category page, template located in _layouts

    def initialize(site, base, directory, category, category_key, template)
      @site = site
      @base = base


      page_file_name = slugify_name(category_key).to_s

      @dir = directory + "/" + page_file_name + "/"
      # @dir is the directory where we want to output the page for current category
      @name =  "index.html"
      # @name is the file_name of the page to generate under the directory

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), template + ".html")
      self.data['title'] = category_key

      # add all the information defined in _data for the current category to the
      # current page (so that we can access it with liquid tags)
      self.data.merge!(category)
    end
  end



  class CategoryPagesGenerator < Generator
    include Slugify
    safe true
    priority :high

    # loop over _config.yml/page_generator list and
    # invoke the CategoryPage constructor to create a page for each category 

    def generate(site)

      # page_gen_data contains the options of the data for which we want to generate

      page_gen_data = site.config['page_generator']
      if page_gen_data
        page_gen_data.each do |d|

          child_template = d['child_template'] || d['data_file']
          parent_key = d['parent_key']
          sub_key = d['sub_key'].split('.')
          sub_key_arr = sub_key[0]
          child_key = sub_key[1]
          out_dir = d['out_dir'] || d['data_file']
          parent_template = d['parent_template']

          if (site.layouts.key? child_template) & (site.layouts.key? parent_template)
            # categories is the list of categories defined in the json|yml data_file
            # this is the list for which we want to generate pages for

            data_file_key = d['data_file']
            categories = site.data[data_file_key]

            # loop through all the categories in the data_file and create the pages in the out_dir directory

            categories.each do |category|
              parent_cat_name = category[parent_key]
              parent_slug_name = slugify_name(parent_cat_name)
              category['parent_slug_name'] = out_dir
              category['child_slug_name'] = parent_slug_name

              site.pages << CategoryPage.new(site, site.source, out_dir, category, parent_cat_name, parent_template)
              
              sub_dir = out_dir + '/' + parent_slug_name

              # loop over the entry in the sub categories of the current parent category and create those pages
              # in the parent catergory directory
              category[sub_key_arr].each do |sub_cat|
                sub_cat_name = sub_cat[child_key]
                sub_cat['parent_slug_name'] = parent_slug_name

                child_slug_name = slugify_name(sub_cat_name)
                sub_cat['child_slug_name'] = child_slug_name                

                site.pages << CategoryPage.new(site, site.source, sub_dir, sub_cat, sub_cat_name, child_template)
              end
              
            end
          else
            puts "ERROR! [CategoryPagesGenerator] Templates: #{parent_template} and/or #{child_template} not found in the _layouts folder" 
          end
        end
      end
    end
  end



  module CategoryPageUrlGenerator

    # Use {{ input | page_url }} in the parent_template layout file to return the sub url to the generated category page

    def page_url(input)
        category_key = input['child_slug_name']
        p_key = input['parent_slug_name']
        link = p_key + "/" + category_key + "/"
        link
    end    
  end

end

Liquid::Template.register_filter(Jekyll::CategoryPageUrlGenerator)
